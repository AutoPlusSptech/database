CREATE FUNCTION fn_variacao_grupo_periodo_porcentagem (
	@data_inicio DATE,
	@data_fim DATE,
	@fk_sensor1 INT = NULL,
	@fk_sensor2 INT = NULL,
	@fk_sensor3 INT = NULL,
	@fk_sensor4 INT = NULL,
	@fk_sensor5 INT = NULL,
	@fk_sensor6 INT = NULL,
	@fk_sensor7 INT = NULL,
	@fk_sensor8 INT = NULL,
	@fk_sensor9 INT = NULL
)
RETURNS TABLE
AS
RETURN(
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
	        r.dt_coleta BETWEEN @data_inicio AND @data_fim
	        AND r.fk_sensor IN (@fk_sensor1, @fk_sensor2, @fk_sensor3, @fk_sensor4, @fk_sensor5, @fk_sensor6, @fk_sensor7, @fk_sensor8, @fk_sensor9) -- Substitua com os IDs dos sensores que deseja agrupar
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
	    variacao_percentual DESC
);


CREATE FUNCTION fn_split_string
(
    @string NVARCHAR(MAX),
    @delimiter CHAR(1)
)
RETURNS @output TABLE (
    id INT IDENTITY(1, 1),
    value NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @start INT, @end INT
    SET @start = 1
    SET @end = CHARINDEX(@delimiter, @string)

    WHILE @start < LEN(@string) + 1
    BEGIN
        IF @end = 0
            SET @end = LEN(@string) + 1

        INSERT INTO @output (value)
        VALUES(SUBSTRING(@string, @start, @end - @start))

        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @string, @start)
    END

    RETURN
END
