from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CustomerViewSet, DailyOrderViewSet, CashPaymentViewSet

# The router automatically creates standard RESTful URLs (GET, POST, PUT, DELETE)
router = DefaultRouter()
router.register(r'customers', CustomerViewSet)
router.register(r'orders', DailyOrderViewSet)
router.register(r'payments', CashPaymentViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]