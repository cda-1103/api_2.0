
from django.urls import path
from backend.data_uploader.views import UploadDataExcel
from backend.data_uploader.products.products import GetHeaders

urlpatterns = [
    path('productos/', UploadDataExcel.as_view(), name='cargar_productos'),
    path('get_headers/', GetHeaders.as_view(), name='obtener_headers'),
]