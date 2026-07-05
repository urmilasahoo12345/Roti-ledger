from django.contrib import admin
from .models import Customer, DailyOrder, CashPayment

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ("name", "custom_price_per_roti", "outstanding_balance")
    readonly_fields = ("outstanding_balance",) # Prevent manual typing, let the system calculate it
    search_fields = ("name",)

@admin.register(DailyOrder)
class DailyOrderAdmin(admin.ModelAdmin):
    list_display = ("date", "customer", "quantity", "status", "total_cost")
    list_filter = ("status", "date")
    date_hierarchy = "date"
    readonly_fields = ("total_cost",)

@admin.register(CashPayment)
class CashPaymentAdmin(admin.ModelAdmin):
    list_display = ("date", "customer", "amount_received")
    date_hierarchy = "date"
