
from django.urls import path
from .views import  upload_products, GetHeaders

urlpatterns = [
    path('productos/', upload_products.as_view(), name='cargar_productos'),
    path('get_headers/', GetHeaders.as_view(), name='obtener_cabeceras'),
] 