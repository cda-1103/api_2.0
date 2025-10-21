from rest_framework.views import APIView 
from rest_framework.response import Response
from rest_framework import status
from django.db import IntegrityError 
import logging
from .serializers import ProductSerializer 
import pandas as pd #importar pandas para manipulación de datos del archivo Excel
from django.db import transaction  #importar transaction para manejar transacciones atómicas
from .models import Products  #importar el modelo Product
from .serializers import ProductSerializer  #importar el serializador ProductSerializer


logger = logging.getLogger('carga_archivo') #configurar el logger para la carga de archivos

class UploadDataExcel(APIView):
    
    def post(self, request): #maneja las solicitudes POST para cargar datos de productos desde un archivo Excel
        excel = request.FILES.get('file')  #obtener el archivo Excel de la solicitud
        
        if not excel:
            logger.error("No se proporcionó ningún archivo Excel."),
            return Response("no se proporcino ningun archivo de excel", status=status.HTTP_400_BAD_REQUEST)
        
        try:
            df = pd.read_excel(excel)  #leer el archivo Excel usando pandas
            df.rename(columns={
                'SerialNumber': 'serial_number',
                'Description': 'description',
                'Category': 'category',
                'Brand': 'brand',
                'Type': 'type',
                'Quantity': 'quantity',
                'Location': 'location'
            }, inplace= True)  #renombrar las columnas del DataFrame para que coincidan con los nombres de los campos del modelo Product

            data_list = df.to_dict(orient='records')  #convertir el DataFrame en una lista de diccionarios, donde cada diccionario representa un registro de producto (esto para que sea compatible con el serializador)

            with transaction.atomic():  #iniciar una transacción atómica para asegurar la integridad de los datos durante la operación de carga, es decir , si algo falla, todos los cambios se revertirán
                count,_ =Products.objects.all().delete()  #eliminar todos los registros existentes en la tabla Product si el modo de carga es 'replace'. se utiliza la , y _ para capturar el número de registros eliminados, _ evita capturar el segundo valor devuelto por delete()
                logger.info(f"Se eliminaron {count} registros existentes antes de la carga.") #registrar la cantidad de registros eliminados en el log
                

                registros_creados = 0 #contador para estadísticas de productos creados 

                for item_data in data_list:
                    serial_number = item_data.get('serial_number')
                    if not serial_number:
                        logger.warning("Se omitió un registro sin serial.")
                        continue  #omitir registros sin serial_number

                    Products.objects.create(
                        serial_number=item_data.get('serial_number'),
                        description=item_data.get('description'),
                        category=item_data.get('category'),
                        brand=item_data.get('brand'),
                        type=item_data.get('type'),
                        quantity=item_data.get('quantity'),
                        location=item_data.get('location')
                    )
                    registros_creados += 1   #incrementar el contador de productos creados

                mensaje = (f"Carga completada."
                           f" Registros creados: {registros_creados}.")
                logger.info(mensaje)
                return Response(mensaje, status=status.HTTP_201_CREATED)
        except IntegrityError as e:
                logger.error(f"Error al cargar datos: {str(e)}")
                return Response(f"Error de integridad al cargar datos: {str(e)}", status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            