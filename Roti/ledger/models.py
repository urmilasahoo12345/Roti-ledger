from django.db import models
from django.db import transaction
from django.dispatch import receiver
from django.db.models.signals import post_save, post_delete
from decimal import Decimal
from django.utils import timezone

class Customer(models.Model):
    name = models.CharField(max_length=100, unique=True)
    custom_price_per_roti = models.DecimalField(max_digits=8, decimal_places=2)
    outstanding_balance = models.DecimalField(
        max_digits=12, decimal_places=2, default=Decimal('0.00')
    )

    def __str__(self):
        return self.name

class DailyOrder(models.Model):
    STATUS_CHOICES = [
        ("PENDING", "Pending"),
        ("DELIVERED", "Delivered"),
        ("SKIPPED", "Skipped"),
    ]

    date = models.DateField()
    created_at = models.DateTimeField(default=timezone.now) # NEW: Exact timestamp
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name="orders")
    quantity = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default="PENDING")
    total_cost = models.DecimalField(max_digits=12, decimal_places=2, editable=False, default=Decimal('0.00'))

    def save(self, *args, **kwargs):
        # Calculate cost BEFORE saving to avoid infinite recursion loops
        self.total_cost = Decimal(self.quantity) * self.customer.custom_price_per_roti
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.customer.name} – {self.date} – {self.get_status_display()}"

class CashPayment(models.Model):
    date = models.DateField()
    created_at = models.DateTimeField(default=timezone.now) # NEW: Exact timestamp
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name="payments")
    amount_received = models.DecimalField(max_digits=12, decimal_places=2)

    def __str__(self):
        return f"{self.customer.name} – {self.date} – {self.amount_received}"


# ==========================================
# SAFE LEDGER AUTOMATION (Signals)
# ==========================================

def recalculate_customer_balance(customer):
    """
    Safely recalculates the entire balance. This avoids bugs where changing an 
    order from 'Delivered' to 'Skipped' fails to update the math correctly.
    """
    with transaction.atomic():
        total_delivered = DailyOrder.objects.filter(
            customer=customer, 
            status='DELIVERED'
        ).aggregate(models.Sum('total_cost'))['total_cost__sum'] or Decimal('0.00')

        total_paid = CashPayment.objects.filter(
            customer=customer
        ).aggregate(models.Sum('amount_received'))['amount_received__sum'] or Decimal('0.00')

        customer.outstanding_balance = total_delivered - total_paid
        customer.save(update_fields=['outstanding_balance'])

@receiver(post_save, sender=DailyOrder)
@receiver(post_delete, sender=DailyOrder)
def update_balance_on_order(sender, instance, **kwargs):
    recalculate_customer_balance(instance.customer)


@receiver(post_save, sender=CashPayment)
@receiver(post_delete, sender=CashPayment)
def update_balance_on_payment(sender, instance, **kwargs):
    recalculate_customer_balance(instance.customer)