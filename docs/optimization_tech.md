# Documentación Técnica: Widgets y Memoria

## 1. Creación de Widgets (Polybar)
Los widgets se diseñaron bajo la premisa de "Eficiencia Primero". 
- **Intervalos:** Se han configurado intervalos de 5s a 10s para módulos de Batería, CPU y RAM.
- **Lógica de Scripting:** El widget de LLM detecta procesos activos mediante `pgrep` para evitar ejecuciones en bucles pesados.

## 2. Gestión de Memoria Profunda
Además de ZRAM, el script `04-llm-optim.sh` modifica parámetros del kernel (`sysctl`):
- `vm.swappiness=100`: Fuerza al kernel a preferir ZRAM sobre la memoria física cuando esta empieza a llenarse.
- `vm.vfs_cache_pressure=50`: Mantiene el cache de archivos en RAM por más tiempo, acelerando la carga de pesos de modelos.

## 3. Control Térmico
Dado que el i5-4200M tiende a calentarse rápidamente en tareas de inferencia:
- Se integra **thermald** con perfiles específicos para el L440.
- Se recomienda el uso de **TLP** en modo "AC" para permitir picos de frecuencia controlados sin llegar al apagado por seguridad.