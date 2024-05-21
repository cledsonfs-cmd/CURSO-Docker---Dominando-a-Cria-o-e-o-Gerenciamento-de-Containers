-- Cria Tabela dicionario da região metropolitana
CREATE TABLE der_ce_coorporativo.regiao_metropolitana (
    id            INTEGER      NOT NULL,
    cor           VARCHAR(8)   NOT NULL,
    descricao     varchar(50)  NOT NULL
) WITHOUT OIDS;
ALTER TABLE ONLY der_ce_coorporativo.regiao_metropolitana  ADD CONSTRAINT pk_regiao_metropolitana   PRIMARY KEY (id);
INSERT INTO der_ce_coorporativo.regiao_metropolitana (id, cor, descricao) VALUES
(0 ,'#000000' ,'Não Definido.'),
(1 ,'#000000' ,'Fortaleza.'),
(2 ,'#000000' ,'Cariri.'),
(3 ,'#000000' ,'Sobral.');
-- Inclui Id da região administrativa na tabela cidade_der
ALTER TABLE der_ce_coorporativo.cidades_der
  ADD COLUMN id_regiao_metropolitana INTEGER DEFAULT 0 NOT NULL;
COMMENT ON COLUMN der_ce_coorporativo.cidades_der.id_regiao_metropolitana
IS 'Indica a qual região metropolitana o municipio pertence';
ALTER TABLE ONLY der_ce_coorporativo.cidades_der
  ADD CONSTRAINT fk_regiao_metropolitana   FOREIGN KEY (id_regiao_metropolitana)
      REFERENCES der_ce_coorporativo.regiao_metropolitana (id);
     
     
-- Associar Municipios com região administrativa Fortaleza

UPDATE der_ce_coorporativo.cidades_der SET id_regiao_metropolitana = 1 WHERE id_cidade in (
select cd.id_cidade  from der_ce_coorporativo.cidades as c
left join der_ce_coorporativo.cidades_der cd on cd.id_cidade =c.id 
where 
TRANSLATE(LOWER(c.nome), 'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÕÔÖóòôõöÚÙÛÜúùûüÇç',
'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuÇc') in (
'aquiraz', 
'cascavel', 
'caucaia', 
'chorozinho', 
'eusebio',
'fortaleza', 
'guaiuba',
'horizonte', 
'itaitinga', 
'maracanau', 
'maranguape', 
'pacajus',
'pacatuba', 
'pindoretama', 
'sao goncalo do amarante', 
'sao luis do curu',
'paraipaba',
'paracuru', 
'trairi') and c.uf ='CE' order by nome);

-- Associar Municipios com região administrativa Carriri
UPDATE der_ce_coorporativo.cidades_der SET id_regiao_metropolitana = 2 WHERE id_cidade in (
select cd.id_cidade  from der_ce_coorporativo.cidades as c
left join der_ce_coorporativo.cidades_der cd on cd.id_cidade =c.id 
where 
TRANSLATE(LOWER(c.nome), 'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÕÔÖóòôõöÚÙÛÜúùûüÇç',
'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuÇc') in (
'barbalha',
'caririacu',
'crato',
'farias brito',
'jardim',
'juazeiro do norte',
'missao velha',
'nova olinda',
'santana do cariri') and c.uf ='CE' order by nome
);

-- Associar Municipios com região administrativa Sobral
UPDATE der_ce_coorporativo.cidades_der SET id_regiao_metropolitana = 3 WHERE id_cidade in (
select cd.id_cidade  from der_ce_coorporativo.cidades as c
left join der_ce_coorporativo.cidades_der cd on cd.id_cidade =c.id 
where 
TRANSLATE(LOWER(c.nome), 'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÕÔÖóòôõöÚÙÛÜúùûüÇç',
'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuÇc') in (
'sobral',
'massape',
'santana do acarau',
'forquilha',
'coreau',
'reriutaba',
'carire',
'varjota',
'graca',
'meruoca',
'frecheirinha',
'pires ferreira',
'mucambo',
'alcantaras',
'groairas',
'moraujo',
'senador sa',
'pacuja'
) and c.uf ='CE' order by nome
);

--Alteração de view
-- der_ce_recursos_humanos.vw_cidade_valor_diarias source

CREATE OR REPLACE VIEW der_ce_recursos_humanos.vw_cidade_valor_diarias
AS SELECT cidadeval.id_cidade,
    estado.uf,
    cidade.nome AS nome_cidade,
    cidade.populacao_estimada,
    cidadeval.valor_percentual_adicional,
    cidadeval.valor_percentual_fixo,
    estado.capital,
    estado.nome AS nome_estado,
    estado.id_pais,
    cider.id_cptec,
    dto.id_cidade_sede,
        CASE
            WHEN cidadeval.id_cidade::text = dto.id_cidade_sede::text THEN true
            ELSE false
        END AS sede_do,
    dto.id_setor,
    COALESCE(cider.id_regiao_metropolitana, 0) AS regiao_metropolitana
   FROM der_ce_recursos_humanos.cidade_valor_diarias cidadeval
     JOIN der_ce_coorporativo.cidades cidade ON cidadeval.id_cidade::text = cidade.id::text
     JOIN der_ce_coorporativo.estados estado ON cidade.uf::text = estado.uf::text
     LEFT JOIN der_ce_coorporativo.cidades_der cider ON cider.id_cidade::text = cidade.id::text
     LEFT JOIN der_ce_coorporativo.distritos_operacionais dto ON cider.id_distrito_operacional = dto.id
  WHERE cidadeval.id_cidade::numeric < 9000000::numeric;
