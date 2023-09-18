#!/bin/bash

# funções
function mostraOpcoes(){
	echo "";
	echo "Arquivo selecionado: $arquivo";
	echo "[v] Visualizar | [e] Editar | [a] Alterar arquivo | [d] Deletar | [q] Sair";
	read opcao;
}


function exibeGrade(){
	clear
	awk 'BEGIN{
	 		FS=":";
	 		horas=0;
			printf ("hor/dia | Segunda\tTerca\t\tQuarta\t\tQuinta\t\tSexta\n");
			print "========|=====================================================================";
	     }
	     {
	     	printf ("  %-3s\t| %-12s %-12s   %-12s    %-12s   %s\n", $1, $2, $3, $4, $5, $6);
	 	if($2 != null){horas+=30;}
	 	if($3 != null){horas+=30;}
	 	if($4 != null){horas+=30;}
	 	if($5 != null){horas+=30;}
	 	if($6 != null){horas+=30;}
	     }
	     END{
	     		printf("\nTotal de Horas: %dh\n", horas);
		}' $arquivo
	mostraOpcoes;
}

function edicao(){
	echo "===================== Inserir na grade =====================";
	echo "<horario -> dia[2a6] turno[M, T e N] horas[12, 34 ou 56]>";
	read -p "Materia:" materia;
	read -p "horario:" horario;
	# avalia expressao
	if [[ "$horario" =~  ^(2|3|4|5|6|23|24|25|26|34|35|36|45|46|234|235|236|245|246|345|346|356|456)(M12|M34|M56|T12|T34|T56|N12|N34)$ ]]; then 
		declare -a vetor;
		vetor=$horario:$materia;
		tmp=.tmp.txt;
		echo "" > $tmp;
		# escreve no arquivo
		awk -v var=$vetor 'BEGIN{
				FS=":";
				split(var, array, ":");
				size = length(array[1]);
				if(size == 4){
					dia=substr( array[1] , 1, 1 );
					hora=substr( array[1] , 2, 3 );
				}else if(size == 5){
					dia[1]=substr( array[1] , 1, 1 );
					dia[2]=substr( array[1] , 2, 1 );
					hora=substr( array[1] , 3, 3 );
				}else if(size == 6){
					dia[1]=substr( array[1] , 1, 1 );
					dia[2]=substr( array[1] , 2, 1 );
					dia[3]=substr( array[1] , 3, 1 );
					hora=substr( array[1] , 4, 3 );
				}
				mat=substr( array[2] , 1, 10 );
			}{
				vetor[1]=$1;vetor[2]=$2;vetor[3]=$3;
				vetor[4]=$4;vetor[5]=$5;vetor[6]=$6;
				if(size == 4){
					vetor[dia]=mat;
				}else if(size == 5){
					vetor[dia[1]]=mat;
					vetor[dia[2]]=mat;
				}else if(size == 6){
					vetor[dia[1]]=mat;
					vetor[dia[2]]=mat;
					vetor[dia[3]]=mat;
					
				}
				if(hora == $1){
					printf("%s:%s:%s:%s:%s:%s\n", vetor[1],vetor[2],vetor[3],vetor[4],vetor[5],vetor[6]);
				}else{
					printf("%s:%s:%s:%s:%s:%s\n", $1,$2,$3,$4,$5,$6);
				}
	
			}' $arquivo > $tmp;
		# sobreescreve
		cp $tmp $arquivo;
		rm $tmp;
		echo "A materia $materia foi inserida no horario $horario"
	else echo "Expressao invalida"; fi
	mostraOpcoes;
}

function criaArquivoVazio(){
	echo -e "M12::::::\nM34::::::\nM56::::::\nT12::::::\nT34::::::\nT56::::::\nN12::::::\nN34::::::" > "$arquivo";
}

function alteraArquivo(){
	echo "Arquivo atual: $arquivo";
	read -p "Insira nome do novo arquivo:" newArq;
	if ! [[ -f "$newArq" ]]; then
		read -p "Esse arquivo nao existe deseja cria-lo? [s/n]:" resp
		if [ "$resp" = 's' ]; then 
			arquivo=$newArq; 
			criaArquivoVazio; 
			echo "Arquivo $arquivo criado"
		elif [ "$resp" = 'n' ]; then 
			echo "Arquivo $newArq nao foi criado" 
		else echo "Opcao invalida. Operacao abortada"
		fi 
	else arquivo=$newArq;fi
	mostraOpcoes;
}

function deletaArquivo(){
	read -p "Tem certeza que deseja deletar a grade atual? [s/n]:" resp
	if [ "$resp" = 's' ]; then 
		criaArquivoVazio; 
		echo "A grade foi removida"
	elif [ "$resp" = 'n' ]; then 
		echo "Operação cancelada" 
	else echo "Opcao invalida. Operacao abortada"
	fi
	mostraOpcoes;
}
 
# variaveis
running=1;
arquivo='grade.txt';

# cria arquivo default caso não exista
if ! [[ -f "$arquivo" ]]; then
	criaArquivoVazio;
fi

# Inicialização
clear
echo "==============================================================="
echo "                        MINHA GRADE                            "
echo "==============================================================="
mostraOpcoes

# loop de execução
while [ "$running" -eq '1' ]; do
	if [ "$opcao" == 'v' ]; then
		exibeGrade;
	elif [ "$opcao" == 'e' ]; then 
		edicao;
	elif [ "$opcao" == 'a' ]; then 
		alteraArquivo;
	elif [ "$opcao" == 'd' ]; then 
		deletaArquivo;
	elif [ "$opcao" == 'q' ]; then 
		running=0;
	else 
		echo "Opcao inválida";
		mostraOpcoes;
	fi
done

exit
