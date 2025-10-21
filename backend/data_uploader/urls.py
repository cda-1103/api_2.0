
from django.urls import path
from .views import UploadDataExcel

urlpatterns = [
    path('productos/', UploadDataExcel.as_view(), name='cargar_productos'),  #ruta para cargar productos via excel
]