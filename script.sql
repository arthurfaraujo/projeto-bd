-- Deleta o banco caso existe, para poder rodar o script novamente sem erros --
DROP DATABASE IF EXISTS projeto;

-- Criação do banco --
CREATE DATABASE projeto;

USE projeto;

-- Criando as tabelas --
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
	  tipo CHAR(1) NOT NULL DEFAULT 'F',
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

-- Triggers --
-- Utilizando trigger para fazer esse check porque dá erro fazer o check na tabela com a fk
DELIMITER $

CREATE TRIGGER chk_gerente_gerenciado_in BEFORE INSERT
ON gerenciado
FOR EACH ROW
BEGIN
    IF NEW.cpf_gerenciado = NEW.cpf_gerente THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: o gerente não pode ser o mesmo funcionário que o gerenciado';
    END IF;
END $

CREATE TRIGGER chk_gerente_gerenciado_up BEFORE UPDATE
ON gerenciado
FOR EACH ROW
BEGIN
    IF NEW.cpf_gerenciado = NEW.cpf_gerente THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: o gerente não pode ser o mesmo funcionário que o gerenciado';
    END IF;
END $

DELIMITER ;

-- Inserindo os dados -- 

INSERT INTO cliente (cpf, nome, email, sexo) VALUES
('11122233344', 'Carlos Silva', 'carlos.silva@exemplo.com', NULL),
('22233344455', 'Ana Souza', 'ana.souza@exemplo.com', 'F'),
('33344455566', 'João Pereira', 'joao.pereira@exemplo.com', 'M'),
('44455566677', 'Maria Silva Bernardes', 'maria.oliveira@exemplo.com', 'F'),
('55566677788', 'Pedro Santos', 'pedro.santos@exemplo.com', 'M'),
('66677788899', 'Fernanda Lima', 'fernanda.lima@exemplo.com', NULL),
('77788899900', 'Lucas Alves', 'lucas.alves@exemplo.com', 'M'),
('88899900011', 'Juliana Costa', 'juliana.costa@exemplo.com', 'F'),
('99900011122', 'Rafael Rodrigues', 'rafael.rodrigues@exemplo.com', 'M'),
('00011122233', 'Beatriz Fernandes Silva', 'beatriz.fernandes@exemplo.com', 'F');

INSERT INTO funcionario (cpf, nome, rg, salario, numero, cep, complemento, meta_vendas, departamento, tipo) VALUES
('12345678901', 'Alice Pereira', '100001', 2800.00, '001', '12345000', 'Apto 101', 1500.00, NULL, 'A'),
('23456789012', 'Bruno Almeida', '100002', 2900.50, '002', '12345001', 'Casa', 1600.00, NULL, 'A'),
('34567890123', 'Clara Martins', '100003', 2750.75, '003', '12345002', 'Apto 202', 1400.00, NULL, 'A'),
('45678901234', 'Diego Ribeiro', '100004', 3000.00, '004', '12345003', 'Casa', 1550.00, NULL, 'A');

INSERT INTO funcionario (cpf, nome, rg, salario, numero, cep, complemento, meta_vendas, departamento, tipo) VALUES
('98765432109', 'Fernanda Souza', '200001', 4500.00, '005', '22345000', 'Apto 301', NULL, 'Vendas', 'G'),
('87654321098', 'Gabriel Lima', '200002', 4600.00, '006', '22345001', 'Casa', NULL, 'Operações', 'G'),
('76543210987', 'Helder Costa', '200003', 4700.00, '007', '22345002', 'Suite 1', NULL, 'Logística', 'G'),
('65432109876', 'Isabela Rodrigues', '200004', 4800.00, '008', '22345003', 'Apto 402', NULL, 'Compras', 'G');

INSERT INTO funcionario (cpf, nome, rg, salario, numero, cep, complemento, meta_vendas, departamento, tipo) VALUES
('11223344556', 'Juliana Ferreira', '300001', 3200.00, '009', '32345000', 'Apto 501', NULL, NULL, 'F'),
('22334455667', 'Marcos Ribeiro', '300002', 3300.00, '010', '32345001', 'Casa', NULL, NULL, 'F'),
('33445566778', 'Natalia Gomes', '300003', 3100.00, '011', '32345002', 'Apto 502', NULL, NULL, 'F'),
('44556677889', 'Otávio Silva', '300004', 3150.00, '012', '32345003', 'Casa', NULL, NULL, 'F');

INSERT INTO produto (nome, data_validade, preco) VALUES
('Arroz Tio João 5kg', '2025-12-31', 19.90),
('Feijão Carioca 1kg', '2024-11-30', 7.50),
('Óleo de Soja 900ml', '2025-06-15', 8.25),
('Açúcar Refinado 1kg', '2024-08-10', 4.80),
('Leite Integral 1L', '2023-10-20', 3.50),
('Café Pilão 500g', '2024-03-30', 12.00),
('Macarrão Espaguete 500g', '2025-01-15', 5.20),
('Detergente Líquido 500ml', '2024-07-05', 2.99),
('Sabonete Dove 90g', '2026-05-25', 1.99),
('Shampoo Pantene 400ml', '2025-09-10', 10.50);

INSERT INTO telefone_cliente (numero, cpf_cliente) VALUES
('5511912345001', '11122233344'),
('5511912345002', '22233344455'),
('5511912345003', '33344455566'),
('5511912345004', '44455566677'),
('5511912345005', '55566677788'),
('5511912345006', '66677788899'),
('5511912345007', '77788899900'),
('5511912345008', '88899900011'),
('5511912345009', '99900011122'),
('5511912345010', '00011122233');

INSERT INTO telefone_funcionario (numero, cpf_funcionario) VALUES
('5511190000001', '12345678901'),
('5511190000002', '12345678901'),
('5511190000003', '23456789012'),
('5511190000004', '34567890123'),
('5511190000005', '45678901234'),
('5511190000006', '98765432109'),
('5511190000007', '87654321098'),
('5511190000008', '76543210987'),
('5511190000009', '65432109876'),
('5511190000010', '11223344556'),
('5511190000011', '22334455667'),
('5511190000012', '33445566778'),
('5511190000013', '44556677889'),

INSERT INTO gerenciado (cpf_gerenciado, cpf_gerente) VALUES
('12345678901', '98765432109'),
('23456789012', '98765432109'),
('34567890123', '98765432109'),
('45678901234', '98765432109'),
('98765432109', '87654321098'),
('11223344556', '98765432109'),
('22334455667', '98765432109'),
('33445566778', '87654321098'),
('76543210987', '65432109876'),
('87654321098', '65432109876');
   
INSERT INTO pedido (cpf_cliente, cpf_funcionario, data, hora, forma_pagamento, numero_serie, imposto) VALUES
('11122233344', '12345678901', '2023-11-01', '08:30:00', 'C', '1001', 1.50),
('22233344455', '23456789012', '2023-11-01', '09:00:00', 'D', '1002', 2.00),
('33344455566', '34567890123', '2023-11-01', '09:30:00', 'P', '1003', 1.75),
('44455566677', '45678901234', '2023-11-01', '10:00:00', 'G', '1004', 2.25),
('55566677788', '12345678901', '2023-11-02', '11:00:00', 'B', '1005', 1.80),
('66677788899', '23456789012', '2023-11-02', '11:30:00', 'C', '1006', 1.90),
('77788899900', '34567890123', '2023-11-02', '12:00:00', 'D', '1007', 2.10),
('88899900011', '45678901234', '2023-11-02', '12:30:00', 'P', '1008', 2.50),
('99900011122', '12345678901', '2023-11-03', '13:00:00', 'G', '1009', 2.00),
('00011122233', '23456789012', '2023-11-03', '13:30:00', 'B', '1010', 1.65);

INSERT INTO cupom (cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido, valor) VALUES
('11122233344', '12345678901', '2023-11-01', '08:30:00', 150.00),
('11122233344', '12345678901', '2023-11-01', '08:30:00', 75.75),
('22233344455', '23456789012', '2023-11-01', '09:00:00', 200.00),
('22233344455', '23456789012', '2023-11-01', '09:00:00', 10.00),
('22233344455', '23456789012', '2023-11-01', '09:00:00', 70.00),
('33344455566', '34567890123', '2023-11-01', '09:30:00', 175.00),
('44455566677', '45678901234', '2023-11-01', '10:00:00', 225.00),
('66677788899', '23456789012', '2023-11-02', '11:30:00', 190.00),
('77788899900', '34567890123', '2023-11-02', '12:00:00', 210.00),
('88899900011', '45678901234', '2023-11-02', '12:30:00', 250.00),
('99900011122', '12345678901', '2023-11-03', '13:00:00', 200.00),
('00011122233', '23456789012', '2023-11-03', '13:30:00', 165.00);

INSERT INTO pedido_produto (codigo_produto, cpf_cliente_pedido, cpf_funcionario_pedido, data_pedido, hora_pedido, quantidade) VALUES
(1, '11122233344', '12345678901', '2023-11-01', '08:30:00', 2),
(3, '11122233344', '12345678901', '2023-11-01', '08:30:00', 1),
(2, '22233344455', '23456789012', '2023-11-01', '09:00:00', 1),
(4, '33344455566', '34567890123', '2023-11-01', '09:30:00', 3),
(5, '44455566677', '45678901234', '2023-11-01', '10:00:00', 2),
(7, '44455566677', '45678901234', '2023-11-01', '10:00:00', 1),
(6, '55566677788', '12345678901', '2023-11-02', '11:00:00', 1),
(8, '66677788899', '23456789012', '2023-11-02', '11:30:00', 2),
(9, '77788899900', '34567890123', '2023-11-02', '12:00:00', 1),
(10, '77788899900', '34567890123', '2023-11-02', '12:00:00', 1),
(1, '88899900011', '45678901234', '2023-11-02', '12:30:00', 2),
(3, '99900011122', '12345678901', '2023-11-03', '13:00:00', 1),
(2, '99900011122', '12345678901', '2023-11-03', '13:00:00', 2),
(4, '00011122233', '23456789012', '2023-11-03', '13:30:00', 1);


-- Consultas --

-- Obter obter a quantidade de pedidos atendidos, meta de vendas, nome, total vendido e o seu gerente
SELECT 
    f.nome as 'Nome do atendente', f.meta_vendas as 'Meta de vendas', COUNT(DISTINCT p.numero_serie) 
    as 'Total de pedidos atendidos', SUM(pp.quantidade * pr.preco) as 'Total vendido', fu.nome as 'Nome do gerente'
FROM funcionario f
JOIN pedido p ON p.cpf_funcionario = f.cpf
JOIN pedido_produto pp ON pp.cpf_funcionario_pedido = f.cpf
JOIN produto pr ON pr.codigo = pp.codigo_produto
JOIN gerenciado g ON g.cpf_gerenciado = f.cpf
JOIN funcionario fu ON fu.cpf = g.cpf_gerente
WHERE f.tipo = 'A'
GROUP BY f.nome, f.meta_vendas, fu.nome;

-- Obter todos os clientes com sexo registrado e seus telefones
SELECT c.nome as 'Nome de cliente com sexo', t.numero as 'Número' FROM cliente c
JOIN telefone_cliente t ON t.cpf_cliente = c.cpf
WHERE sexo IS NOT NULL;

-- Obter soma, média e maior salário dos funcionários agrupando pelos tipos, filtrando apenas os tipos que tem média salarial maior que 3000
SELECT tipo as 'Tipo de funcionário', SUM(salario) as 'Soma dos salários', 
ROUND(AVG(salario), 2) as 'Média dos salários', MAX(salario) as 'Maior salário'
FROM funcionario GROUP BY tipo
HAVING AVG(salario) > 3000;

-- Obter a contagem de pedidos que utilizam débito e pix como forma de pagamento
SELECT forma_pagamento as 'Forma de pagamento', COUNT(*) as 'Quantidade de pedidos' FROM pedido
WHERE forma_pagamento IN ('P', 'D')
GROUP BY forma_pagamento;

-- Obter número de série, data, hora, total, quantidade de itens e de cupons de pedidos que tenham total entre 10 e 100
SELECT pe.numero_serie as 'Número de série', pe.data as 'Data da compra', 
pe.hora as 'Hora da compra', SUM(pp.quantidade * pr.preco) as 'Total', 
SUM(pp.quantidade) as 'Quantidade de itens', COUNT(DISTINCT c.codigo) as 'Quantidade de cupons'
FROM pedido pe 
JOIN pedido_produto pp
ON pe.cpf_cliente = pp.cpf_cliente_pedido
    AND pe.cpf_funcionario = pp.cpf_funcionario_pedido
    AND pe.data = pp.data_pedido 
    AND pe.hora = pp.hora_pedido
JOIN produto pr
    ON pp.codigo_produto = pr.codigo
LEFT JOIN cupom c
ON pe.cpf_cliente = c.cpf_cliente_pedido
    AND pe.cpf_funcionario = c.cpf_funcionario_pedido
    AND pe.data = c.data_pedido 
    AND pe.hora = c.hora_pedido
GROUP BY pe.numero_serie, pe.data, pe.hora
HAVING SUM(pp.quantidade * pr.preco) BETWEEN 10 AND 100;

-- Obter todos os clientes que tenham Silva em alguma parte de seu nome
SELECT * FROM cliente
WHERE nome LIKE '%Silva%';
