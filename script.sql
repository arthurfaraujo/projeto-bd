CREATE TABLE cliente (
	  cpf CHAR(11) PRIMARY KEY,
	  nome VARCHAR(45) NOT NULL,
	  email VARCHAR(45) UNIQUE NOT NULL,
	  sexo CHAR(1),
	  CONSTRAINT check_sexo CHECK (sexo IN ('M', 'F') OR sexo IS NULL)
);

CREATE TABLE funcionario (
	  cpf CHAR(11) PRIMARY KEY,
	  nome VARCHAR(200) NOT NULL,
	  rg VARCHAR(50) UNIQUE NOT NULL,
	  salario DECIMAL(20, 2) NOT NULL,
	  numero VARCHAR(10) NOT NULL,
	  cep CHAR(8) NOT NULL,
	  complemento VARCHAR(100),
	  meta_vendas DECIMAL(20, 2),
	  departamento VARCHAR(100),
	  tipo CHAR(1) NOT NULL,
	  CONSTRAINT check_tipo CHECK (
		    (tipo = 'A' AND meta_vendas IS NOT NULL AND departamento IS NULL) OR 
		    (tipo = 'G' AND departamento IS NOT NULL AND meta_vendas IS NULL) OR
		    (tipo = 'F' AND departamento IS NULL AND meta_vendas IS NULL)
	  )
);

CREATE TABLE produto (
	  codigo INT AUTO_INCREMENT PRIMARY KEY,
	  nome VARCHAR(100) NOT NULL,
	  data_validade DATE NOT NULL,
	  preco DECIMAL(10, 2) NOT NULL
);

CREATE TABLE telefone_cliente (
		numero VARCHAR(20),
		cpf_cliente CHAR(11),
		FOREIGN KEY (cpf_cliente) REFERENCES cliente(cpf)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		PRIMARY KEY (numero, cpf_cliente)
);

CREATE TABLE telefone_funcionario (
		numero VARCHAR(20),
		cpf_funcionario CHAR(11),
		FOREIGN KEY (cpf_funcionario) REFERENCES funcionario(cpf)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		PRIMARY KEY (numero, cpf_funcionario)
);

CREATE TABLE gerenciado (
    cpf_gerenciado CHAR(11),
    cpf_gerente CHAR(11),
    FOREIGN KEY (cpf_gerenciado) REFERENCES funcionario(cpf)
        ON UPDATE CASCADE,
    FOREIGN KEY (cpf_gerente) REFERENCES funcionario(cpf)
        ON UPDATE CASCADE,
    PRIMARY KEY (cpf_gerenciado, cpf_gerente)
);

CREATE TABLE pedido (
		cpf_cliente CHAR(11),
		cpf_funcionario CHAR(11),
		data DATE,
		hora TIME,
		forma_pagamento CHAR(1) NOT NULL,
		numero_serie VARCHAR(15) UNIQUE NOT NULL,
		imposto DECIMAL(10, 2) NOT NULL,
		CONSTRAINT check_forma_pagamento CHECK (forma_pagamento IN ('C', 'D', 'P', 'G', 'B')),
		FOREIGN KEY (cpf_cliente) REFERENCES cliente(cpf)
				ON UPDATE CASCADE,
		FOREIGN KEY (cpf_funcionario) REFERENCES funcionario(cpf)
				ON UPDATE CASCADE,
		PRIMARY KEY (cpf_cliente, cpf_funcionario, data, hora)
);

CREATE TABLE cupom (
		codigo INT AUTO_INCREMENT,
		cpf_cliente_pedido CHAR(11),
		cpf_funcionario_pedido CHAR(11),
		data_pedido DATE,
		hora_pedido TIME,
		valor DECIMAL(7, 2) NOT NULL,
		FOREIGN KEY (cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido) 
				REFERENCES pedido(cpf_cliente, cpf_funcionario, data, hora)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		PRIMARY KEY (codigo, cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido)
);

CREATE TABLE pedido_produto (
		codigo_produto INT AUTO_INCREMENT,
		cpf_cliente_pedido CHAR(11),
		cpf_funcionario_pedido CHAR(11),
		data_pedido DATE,
		hora_pedido TIME,
		quantidade INT NOT NULL,
		FOREIGN KEY (cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido) 
				REFERENCES pedido(cpf_cliente, cpf_funcionario, data, hora)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		FOREIGN KEY (codigo_produto) REFERENCES produto(codigo)
				ON DELETE CASCADE
				ON UPDATE CASCADE,
		PRIMARY KEY (codigo_produto, cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido)
);
