
import numpy as np

#Função para média
def media(x):
  resultado = sum(x)/len(x)
  return resultado

# Função para variância amostral  
def variancia(x):
  resul_var = sum((np.array(x)-media(x))**2)/(len(x)-1)
  return resul_var

