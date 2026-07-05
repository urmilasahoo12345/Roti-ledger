from rest_framework import viewsets
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Customer, DailyOrder, CashPayment
from .serializers import CustomerSerializer, DailyOrderSerializer, CashPaymentSerializer

class CustomerViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated] # Locks the endpoint
    queryset = Customer.objects.all().order_by('name')
    serializer_class = CustomerSerializer

class DailyOrderViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated] # Locks the endpoint
    queryset = DailyOrder.objects.all().order_by('-created_at')
    
    # THE FIX: This line was missing, causing the AssertionError!
    serializer_class = DailyOrderSerializer 
    
    filterset_fields = ['date', 'status', 'customer']

class CashPaymentViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated] # Locks the endpoint
    queryset = CashPayment.objects.all().order_by('-created_at')
    serializer_class = CashPaymentSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['customer']