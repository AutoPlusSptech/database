SELECT
    registro.fk_sensor,
    registro.dt_coleta,
    registro.valor,
    COALESCE(LAG(registro.valor) OVER (PARTITION BY registro.fk_sensor ORDER BY registro.dt_coleta), 0) AS valor_anterior,
    CASE 
        WHEN LAG(registro.valor) OVER (PARTITION BY registro.fk_sensor ORDER BY registro.dt_coleta) IS NULL THEN 0
        ELSE ((registro.valor - LAG(registro.valor) OVER (PARTITION BY registro.fk_sensor ORDER BY registro.dt_coleta)) / LAG(registro.valor) OVER (PARTITION BY registro.fk_sensor ORDER BY registro.dt_coleta)) * 100 
    END AS variacao_percentual
FROM 
    registro
WHERE dt_coleta BETWEEN '2024-07-01' AND '2024-07-30' AND fk_sensor = 209 ;

-- CTE para numerar as linhas dentro de cada partição (grupo de sensores)
WITH NumeredCTE AS (
    SELECT
        r.fk_sensor,
        r.dt_coleta,
        r.valor,
        ROW_NUMBER() OVER (PARTITION BY r.fk_sensor ORDER BY r.dt_coleta DESC) AS rn
    FROM 
        registro r
    WHERE 
        r.dt_coleta BETWEEN '2024-06-01' AND '2024-07-30'
        AND r.fk_sensor IN (208, 209, 210, 211, 216) -- Substitua com os IDs dos sensores que deseja agrupar
),

-- CTE para selecionar os últimos 5 registros de cada sensor
Top5CTE AS (
    SELECT
        fk_sensor,
        dt_coleta,
        valor,
        rn
    FROM
        NumeredCTE
    WHERE
        rn <= 5
)

-- CTE para obter o primeiro e o último valor dentro dos últimos 5 registros
, MinMaxCTE AS (
    SELECT
        fk_sensor,
        MAX(CASE WHEN rn = 1 THEN valor END) AS valor_mais_recente,
        MAX(CASE WHEN rn = 5 THEN valor END) AS valor_menos_recente
    FROM
        Top5CTE
    GROUP BY
        fk_sensor
)

-- CTE para calcular a variação percentual entre o primeiro e o último valor dos últimos 5 registros
, VariacaoCTE AS (
    SELECT
        fk_sensor,
        valor_menos_recente,
        valor_mais_recente,
        CASE 
            WHEN valor_menos_recente = 0 THEN 0
            ELSE ((valor_mais_recente - valor_menos_recente) / NULLIF(valor_menos_recente, 0)) * 100 
        END AS variacao_percentual
    FROM
        MinMaxCTE
)

-- Seleção da maior variação percentual dentro de cada grupo de sensores
SELECT TOP 1
    fk_sensor,
    valor_menos_recente,
    valor_mais_recente,
    variacao_percentual
FROM
    VariacaoCTE
ORDER BY
    variacao_percentual DESC;
   
  STRING_SPLIT()
    
CREATE VIEW vw_word_cloud AS
WITH SplitTweets AS (
    SELECT
        value AS Palavra
    FROM
        tweets
        CROSS APPLY STRING_SPLIT(tweet, ' ')
    WHERE
        dt_insercao > '2024-06-10'
)
SELECT
    STRING_AGG(Palavra, ' ') AS Palavras
FROM
    SplitTweets
WHERE
    PATINDEX('%[0-9]%', Palavra) = 0 AND Palavra NOT LIKE 'KM';
   
SELECT * FROM vw_word_cloud;

select * from sensor where fk_veiculo = 1;

SELECT status FROM veiculo WHERE id_veiculo = 1;

SELECT COUNT(id_tweet) FROM tweets WHERE c

update veiculo set status = 'Revisão recomendada' where id_veiculo = 1;

select * from veiculo;

SELECT * FROM fn_variacao_grupo_periodo_porcentagem('2023-12-01', '2024-06-30', 9,null,null,null,null,null,null,null,null);
   
    
CREATE VIEW vw_carros_revisao_necessario_updated_at AS
SELECT 1 as valor_count, id_veiculo, dt_atualizacao FROM veiculo WHERE status LIKE 'Revisão Necessária';

CREATE VIEW vw_carros_cadastrados AS
SELECT 1 as valor_count, id_veiculo, dt_cadastro FROM veiculo;

SELECT * FROM vw_carros_cadastrados;
 
SELECT * FROM vw_carros_revisao_necessario_updated_at;