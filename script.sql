CREATE TABLE cliente (
	  cpf CHAR(11) PRIMARY KEY,
	  nome VARCHAR(45) NOT NULL,
	  email VARCHAR(45) UNIQUE NOT NULL,
	  sexo CHAR(1),
	  CONSTRAINT check_sexo CHECK (sexo IN ('M', 'F'))
);

CREATE TABLE funcionario (
	  cpf CHAR(11) PRIMARY KEY,
	  nome VARCHAR(200) NOT NULL,
	  rg VARCHAR(50) UNIQUE NOT NULL,
	  salario DECIMAL(20) NOT NULL,
	  numero VARCHAR(10) NOT NULL,
	  cep CHAR(8) NOT NULL,
	  complemento VARCHAR(100),
	  meta_vendas DECIMAL(20),
	  departamento VARCHAR(100),
	  tipo CHAR(1) NOT NULL,
	  CONSTRAINT check_tipo CHECK (
		    (tipo = 'A' AND meta_vendas IS NOT NULL AND departamento IS NULL) OR 
		    (tipo = 'G' AND departamento IS NOT NULL AND meta_vendas IS NULL) OR
		    (tipo = 'F' AND departamento IS NULL AND meta_vendas IS NULL)
	  )
);

CREATE TABLE produto (
	  codigo INT,
	  nome VARCHAR(100),
	  data_validade DATE,
	  preco DECIMAL(10)
);
