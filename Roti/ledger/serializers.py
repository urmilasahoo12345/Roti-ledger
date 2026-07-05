from rest_framework import serializers
from .models import Customer, DailyOrder, CashPayment

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

class DailyOrderSerializer(serializers.ModelSerializer):
    # This pulls the customer's name so the mobile app doesn't just show an ID number
    customer_name = serializers.ReadOnlyField(source='customer.name')
    
    class Meta:
        model = DailyOrder
        fields = '__all__'

class CashPaymentSerializer(serializers.ModelSerializer):
    customer_name = serializers.ReadOnlyField(source='customer.name')

    class Meta:
        model = CashPayment
        fields = '__all__'