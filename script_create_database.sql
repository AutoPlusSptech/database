USE vehicle_monitoring;

CREATE TABLE veiculo (
	id_veiculo INT PRIMARY KEY IDENTITY (1,1),
	placa VARCHAR(8) NOT NULL UNIQUE,
	modelo VARCHAR(100) NOT NULL,
	ano INT NOT NULL CHECK (ano > 2007),
	status VARCHAR(50) NOT NULL,
	dt_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	dt_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE sensor (
	id_sensor INT PRIMARY KEY IDENTITY (1,1),
	unidade_medida VARCHAR(8) NOT NULL,
	modelo VARCHAR(50) NOT NULL,
	dt_instalacao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	fk_veiculo INT FOREIGN KEY REFERENCES veiculo(id_veiculo) NOT NULL
);

CREATE TABLE registro (
	id_registro INT PRIMARY KEY IDENTITY (1,1),
	valor FLOAT NOT NULL,
	dt_coleta DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	fk_sensor INT FOREIGN KEY REFERENCES sensor(id_sensor) NOT NULL
);

CREATE TABLE tweets (
	id_tweet INT PRIMARY KEY IDENTITY (1,1),
	usuario VARCHAR(100) NOT NULL,
	tweet VARCHAR(5000) NOT NULL,
	classificacao_sentimento FLOAT NOT NULL,
	tweet_tratado VARCHAR(5000) NOT NULL,
	dt_insercao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE instancia (
	id_instancia INT PRIMARY KEY IDENTITY (1,1),
	nome VARCHAR(100) NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE registro_instancia (
	id_registro_instancia INT PRIMARY KEY IDENTITY (1,1),
	cpu FLOAT,
	ram FLOAT,
	disco FLOAT,
	dt_insercao DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
	fk_instancia INT FOREIGN KEY REFERENCES instancia(id_instancia)
)


CREATE INDEX idc_veiculo_ano ON veiculo(ano);
CREATE INDEX idc_veiculo_placa ON veiculo(placa);
CREATE INDEX idc_veiculo_dt_cadastro ON veiculo(dt_cadastro);

CREATE INDEX idc_sensor_modelo ON sensor(modelo);
CREATE INDEX idc_sensor_dt_instalacao ON sensor(dt_instalacao);
CREATE INDEX idc_sensor_fk_veiculo ON sensor(fk_veiculo);

CREATE INDEX idc_registro_dt_coleta ON registro(dt_coleta);
CREATE INDEX idc_registro_fk_sensor ON registro(fk_sensor);