#!/bin/sh

echo "Iniciando o containr"

for i in 1 2 3 4 5; do
  echo "Contador: $1"
done

echo "Processo realizado, serviço en execução"

echo "Iniciando o processo de 5 segundos"
sleep 5s
echo "5 segundos depois"