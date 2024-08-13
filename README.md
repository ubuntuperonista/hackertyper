# hackertyper
Un simulador de productividad

	-q "sale tras" n presiones
	-l "longitud de mecanografiado por caracter" por defecto: 4
	-f "falla al hackear"
	-s "hackeo exitoso"
	-g "verde monocromático"
	-h "Muestra esta ayuda..."
 
	Ejemplo: -l 20 -q 10 -f -g
		Cada presion de tecla mostrará 20 caracteres
		esto continúa 10 veces (10 presiones antes de que termine)
		una vez que termina, fallará
		todo el texto sale en verde
 
	También note que presionar ` saltará directamente a "hackeo" (o falla)
	Este código es un espaguetti, puedo considerar limpiarlo
	(Intente usar los mismos valores para -q y -l)
