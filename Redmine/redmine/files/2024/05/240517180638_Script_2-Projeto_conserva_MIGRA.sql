
-- =============================================================================
--
-- INICIO: M I G R A Ç Ã O   d o s   D A D O S   E N T R E   S C H E M A S
--
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SANEAR DADOS do SELECT ABAIXO
-- -----------------------------------------------------------------------------
-- Relação de medições de conserva não encaminhadas para financeiro
SELECT 
  -- Ids Relevantes
  ctr.id                  AS id_contrato,
  med.id                  AS id_medicao,
  --Dados do Contrato 
  ctr.nr_contrato_der     AS Nr_Contrato, 
  ctr.objeto              AS Objeto_Contrato,
  sct.descricao           AS Status_Contrato,
  ctd.razao_social        AS Contratada,
  dop.nome                AS Distrito,
  -- dados da Medição
  med.nr_medicao          AS Nr_Medicao,
  med.nr_protocolo        AS Protocolo,
  med.data_hora_protocolo AS Dth_Protoc,
  pan.ano_mes             AS Periodo,
  med.data_inicio         AS Inicio,
  med.data_fim            AS Fim,
  med.valor_medido        AS Medido_PI,
  med.valor_reajuste      AS Reajuste,
  med.valor_ref_glosa     AS Ref_Glosa,
  med.valor_ajuste_contratual AS Ajuste,
  med.valor_processo      AS Total,
  sfm.descricao           AS Status_Medicao
FROM der_ce_contrato.contratos         ctr
JOIN der_ce_contrato.status_contrato   sct ON sct.id = ctr.id_status
JOIN der_ce_coorporativo.vw_contratada ctd ON ctd.id = ctr.id_contratada
JOIN der_ce_contrato_medicoes.medicoes_contratos     med ON ctr.id = med.id_contrato
JOIN der_ce_contrato_medicoes.status_processo_medicao_contrato   sfm ON sfm.id = med.id_status
LEFT JOIN der_ce_medicao.periodos_medicoes_obras     pan ON pan.id = med.id_periodo
LEFT JOIN der_ce_coorporativo.distritos_operacionais dop ON dop.id = ctr.id_distrito
WHERE ctr.tipo          = 2 -- 5-conserva
   AND med.id_status   <= 2 -- Ainda Não Enviado p/ financeiro
  AND med.valor_medido <> 0 -- Somente Medição com Valor
ORDER BY ctr.nr_contrato_der, med.nr_medicao;

-- ===============================================================================
-- INICIO: Ações de preparação para importação dos dados entre schemas
-- ===============================================================================

-- Criação dos atributos temporarios para migração dos dados
ALTER TABLE controle_conservacao.medicoes
  ADD COLUMN id_old INTEGER NOT NULL;

COMMENT ON COLUMN controle_conservacao.medicoes.id_old
IS 'Campo Temporario para migração dos dados do schema der_ce_contratos_medicoes.';

-- Migrar dados das tabelas do schema der_ce_contratos_medicoes para controle_conservacao 
DELETE FROM  controle_conservacao.medicoes_historicos;
DELETE FROM  controle_conservacao.medicoes_ajustes;
DELETE FROM  controle_conservacao.medicoes;

ALTER SEQUENCE controle_conservacao.sq_medicoes            INCREMENT 1 MINVALUE 1  MAXVALUE 2147483647 START 1  RESTART 1 CACHE 1  NO CYCLE;
ALTER SEQUENCE controle_conservacao.sq_medicoes_ajustes    INCREMENT 1 MINVALUE 1  MAXVALUE 2147483647 START 1  RESTART 1 CACHE 1  NO CYCLE;
ALTER SEQUENCE controle_conservacao.sq_medicoes_historicos INCREMENT 1 MINVALUE 1  MAXVALUE 2147483647 START 1  RESTART 1 CACHE 1  NO CYCLE;

-- ===============================================================================
-- FIM: Ações de preparação para importação dos dados entre schemas
-- ===============================================================================
-- Insere a comissão de fiscalização ATIVA dos contratos VIGENTES
INSERT INTO controle_conservacao.contratos_fiscais (id_contrato, id_tipo_fiscal, id_fiscal) VALUES 
(2797, 1, '30000854'), (2797, 2, '01013017'),                        -- Referente ao Contrato: 00462020
                       (2865, 2, '01401211'), (2865, 3, '00979511'), -- Referente ao Contrato: 01272021
(2785, 1, '30000811'), (2785, 2, '70025310'), (2785, 3, '00979511'), -- Referente ao Contrato: 00242020
(2844, 1, '30000870'), (2844, 2, '70024012'), (2844, 3, '00981915'), -- Referente ao Contrato: 00412021
(2784, 1, '30000889'), (2784, 2, '70024314'), (2784, 3, '00976512'), -- Referente ao Contrato: 00232020
                       (3092, 2, '30009541'),                        -- Referente ao Contrato: 00062024
(2769, 1, '00976512'), (2769, 2, '30009541'),                        -- Referente ao Contrato: 00372019
(2806, 1, '30000803'), (2806, 2, '01401211'), (2806, 3, '00976512'), -- Referente ao Contrato: 00662020
(2859, 1, '30000846'), (2859, 2, '70023911'), (2859, 3, '01019910'), -- Referente ao Contrato: 00942021
(2786, 1, '3000082X'), (2786, 2, '70019612'), (2786, 3, '00976512'), -- Referente ao Contrato: 00262020
(2804, 1, '30000749'), (2804, 2, '70011115'), (2804, 3, '70012715'), -- Referente ao Contrato: 00612020
(3088, 1, '3000955X'), (3088, 2, '70019612'), (3088, 3, '01019910'); -- Referente ao Contrato: 03252023



-- ===============================================================================
-- INICIO: Ações de importação dos dados entre schemas
-- ===============================================================================

-- Insere o registro das medições de conserva
INSERT INTO controle_conservacao.medicoes
 (id_old,
  id_contrato,    nr_medicao,      nr_protocolo,   data_hora_protocolo, data_inicio,    
  data_fim,       valor_medido,    valor_reajuste, valor_ref_glosa,     valor_ajuste_contratual,    
  valor_processo, descricao_glosa, descricao_ajuste_contratual,         obs_responsavel,
  id_periodo,     id_status_fisico,id_status_financeiro, id_despesa,    id_despesa_contrato_tipo1,  
  id_despesa_contrato_tipo2,       id_despesa_contrato_tipo3,           id_pre_liquidacao,  
  id_periodo_vigencia,             doc_digitais_conferido
)
SELECT 
  med.id,                   -- id_old
  med.id_contrato,          -- id_contrato
  med.nr_medicao,           -- nr_medicao
  med.nr_protocolo,         -- nr_protocolo
  med.data_hora_protocolo,  -- data_hora_protocolo
  med.data_inicio,          -- data_inicio
  med.data_fim,             -- data_fim
  med.valor_medido,         -- valor_medido
  med.valor_reajuste,       -- valor_reajuste
  med.valor_ref_glosa,      -- valor_ref_glosa
  med.valor_ajuste_contratual, -- valor_ajuste_contratual
  med.valor_processo,       -- valor_processo
  med.descricao_glosa,      -- descricao_glosa
  med.descricao_ajuste_contratual, -- descricao_ajuste_contratual
  med.obs_responsavel,      -- obs_responsavel
  med.id_periodo,           -- id_periodo
  CASE WHEN med.id_status IN (1,2) -- SE Status = 1-AAD 2-ARP
       THEN 6                      -- ENTAO Statu Fisico = 6-Aguardando Administrativo
       ELSE 7                      -- SENAO Statu Fisico = 7-FECHADA
  END,                      -- id_status_fisico
  CASE WHEN med.id_status IN (1,2) THEN 0 -- SE Status = 1-AAD 2-ARP ENTAO Statu Finsnceiro = 0-Ainda Não Encaminhado
       WHEN med.id_status = 3 THEN COALESCE(des.id_status,0) 
       WHEN med.id_status = 4 THEN 4
       WHEN med.id_status = 5 THEN 5
       WHEN med.id_status = 6 THEN 6
       WHEN med.id_status = 7 THEN 7
       WHEN med.id_status = 8 THEN 9       
  END,                      -- id_status_financeiro
  med.id_despesa,           -- id_despesa
  med.id_despesa_contrato_tipo1, -- id_despesa_contrato_tipo1
  med.id_despesa_contrato_tipo2, -- id_despesa_contrato_tipo2
  med.id_despesa_contrato_tipo3, -- id_despesa_contrato_tipo3
  med.id_pre_liquidacao,    -- id_pre_liquidacao
  med.id_periodo_vigencia,  -- id_periodo_vigencia
  FALSE                     -- doc_digitais_conferido
FROM der_ce_contrato_medicoes.medicoes_contratos med
JOIN der_ce_contrato.contratos                   ctr ON ctr.id = med.id_contrato
LEFT JOIN der_ce_financeiro_despesa.despesas     des ON des.id = med.id_despesa
WHERE ctr.tipo = 2; -- 2-Contrato Tipo Conservavação


-- -----------------------------------------------------------------
-- Atualiza ultima Medição do contrato de conserva que estão vigente
UPDATE der_ce_contrato.contratos 
   SET id_medicao_atual_conserva = NULL
 WHERE tipo=2;

-- -----------------------------------------------------------------
-- Atualiza ultima Medição do contrato de conserva que estão vigente
UPDATE der_ce_contrato.contratos tab
   SET id_medicao_atual_conserva = qry.id_medicao_ultima_medicao_registrata
  FROM (-- Recupera Id da Ultima Medição Por Contrato
        SELECT md1.id_contrato, 
               md1.id AS id_medicao_ultima_medicao_registrata
          FROM controle_conservacao.medicoes md1
          JOIN (-- Recupera NR da Ultima medição por contrato
                SELECT med.id_contrato,
                       max(med.nr_medicao)  nr_medicao 
                  FROM controle_conservacao.medicoes med
                  JOIN der_ce_contrato.contratos              ctr ON ctr.id = med.id_contrato
                 WHERE ctr.tipo=2 -- 2-Contrato de Conserva
              GROUP BY med.id_contrato
               ) md2 ON md1.id_contrato = md2.id_contrato -- Mesmo Contrato
                  AND md1.nr_medicao = md2.nr_medicao   -- Mesma Medição (ultima
       ) qry
WHERE tab.id = qry.id_contrato;

-- -----------------------------------------------------------------
-- Atualiza Status de FISICO de Medições ZERO Antigas
UPDATE controle_conservacao.medicoes tab
   SET id_status_fisico     = 7 -- 7-Medição Fechada
  FROM (SELECT med.id
          FROM der_ce_contrato.contratos     ctr
          JOIN controle_conservacao.medicoes med ON ctr.id = med.id_contrato
         WHERE med.id_status_fisico IN (3,4,5,6) -- Que não estejam Fechada
           AND med.valor_processo    = 0 -- Que o valor seja ZERO
       ) qry
WHERE tab.id = qry.id;

-- Atualiza Status FINANCEIRO de Medições ZERO Antigas
UPDATE controle_conservacao.medicoes tab
   SET id_status_financeiro = 9  -- 9-Medição ZERO
  FROM (SELECT med.id
          FROM controle_conservacao.medicoes med
         WHERE med.id_status_fisico = 7 -- Medições Fechada
           AND med.id_status_financeiro <> 9
           AND med.valor_processo   = 0 -- Que o valor seja ZERO
       ) qry
WHERE tab.id = qry.id;

-- -----------------------------------------------------------------
-- Insere o registro Ajustes das medições de conserva
INSERT INTO controle_conservacao.medicoes_ajustes
  (id_medicao, autorizado_por, motivo, data_ajuste, valor_anterior, valor_ajuste, novo_valor)
SELECT med.id AS id_medicao,
       mca.autorizado_por,
       mca.motivo,
       mca.data_ajuste,
       mca.valor_anterior,
       mca.valor_ajuste,
       mca.novo_valor
FROM der_ce_contrato_medicoes.medicoes_contratos_ajustes mca
JOIN controle_conservacao.medicoes                       med ON med.id_old = mca.id_medicao
ORDER BY med.id, mca.id_medicao;

-- -----------------------------------------------------------------
-- Insere os registros de Historico das medições de conserva
INSERT INTO controle_conservacao.medicoes_historicos
(id_medicao, data_hora, id_tipo_historico, matricula, observacao)
SELECT med.id AS id_medicao,
       mch.data_hora,       
       CASE WHEN mch.id_tipo_historico = 4 THEN 13 -- Protocolada
            WHEN mch.id_tipo_historico = 6 THEN 14 -- Encaminhado para Financeiro
            ELSE mch.id_tipo_historico
       END AS id_tipo_historico,
       mch.matricula,
       mch.observacao
FROM der_ce_contrato_medicoes.medicoes_contratos_historicos mch
JOIN controle_conservacao.medicoes                 med ON med.id_old = mch.id_medicao
ORDER BY med.id, mch.id_medicao;
-- ===============================================================================
-- FIM: Ações de importação dos dados entre schemas
-- ===============================================================================

-- ===============================================================================
-- INICIO: ATUALIZAÇÔES PARA INTEGRAÇÂO
-- ===============================================================================

-- Atualiza a Tabela: [despesas] o campo [id_despesa_origem] com nova [id_medicao] 
UPDATE der_ce_financeiro_despesa.despesas TAB
   SET id_despesa_origem = qry.id_medicao
  FROM (SELECT des.id, 
               med.id AS id_medicao 
          FROM der_ce_financeiro_despesa.despesas des 
          JOIN controle_conservacao.medicoes      med ON des.id = med.id_despesa  AND des.id_tipo_origem = 2
       ) qry
 WHERE tab.id = qry.id;

-- Atualiza a Tabela: [pre_liquidacoes] o campo: [id_pre_liquidacao]
UPDATE der_ce_financeiro_imposto.pre_liquidacoes TAB
   SET id_despesa_origem = qry.id_medicao
  FROM (SELECT pre.id, 
               med.id AS id_medicao 
          FROM der_ce_financeiro_imposto.pre_liquidacoes pre
          JOIN controle_conservacao.medicoes             med ON pre.id = med.id_pre_liquidacao AND pre.id_tipo_origem = 2
       ) qry
 WHERE tab.id = qry.id;

-- Atualiza campo: [id_medicao] na tabela: [er_ce_contrato_despesas.despesas_contrato_x_medicoes]
UPDATE der_ce_contrato_despesas.despesas_contrato_x_medicoes TAB
   SET id_medicao = qry.id_medicao
  FROM (SELECT dpm.id, med.id AS id_medicao 
          FROM controle_conservacao.medicoes                         med  
          JOIN der_ce_contrato_despesas.despesas_contrato_x_medicoes dpm ON med.id_old = dpm.id_medicao
          JOIN der_ce_contrato_despesas.despesas_contrato            dpc ON dpc.id = dpm.id_despesa_contrato --AND dpc.id_tipo= 1 -- 1-Reajuste fora PAdrão
          JOIN der_ce_contrato.contratos                             ctr ON ctr.id = dpc.id_contrato         AND ctr.tipo   = 2 -- 2-Conserva
       ) qry
 WHERE tab.id = qry.id;

-- ===============================================================================
-- FIM: ATUALIZAÇÔES PARA INTEGRAÇÂO
-- ===============================================================================
 
-- ===============================================================================
-- INICIO: Ações de encerramento da importação dos dados
-- ===============================================================================

-- -----------------------------------------------------------------------------
-- Exclui registros anteriores no SCHEMA: 'der_ce_contrato_medicoes'
-- -----------------------------------------------------------------------------
-- Exclui registros de historico
DELETE FROM der_ce_contrato_medicoes.medicoes_contratos_canceladas
 WHERE id_medicao IN (SELECT tab.id_medicao
                        FROM der_ce_contrato_medicoes.medicoes_contratos_canceladas tab
                        JOIN controle_conservacao.medicoes med ON med.id_old = tab.id_medicao);
                
-- Exclui registros de historico
DELETE FROM der_ce_contrato_medicoes.medicoes_contratos_historicos
 WHERE id IN (SELECT tab.id
                FROM der_ce_contrato_medicoes.medicoes_contratos_historicos tab
                JOIN controle_conservacao.medicoes         med ON med.id_old = tab.id_medicao);
                
-- Exclui registros de ajustes da medição
DELETE FROM der_ce_contrato_medicoes.medicoes_contratos_ajustes
 WHERE id IN (SELECT tab.id
                FROM der_ce_contrato_medicoes.medicoes_contratos_ajustes tab
                JOIN controle_conservacao.medicoes         med ON med.id_old = tab.id_medicao);
                
-- Exclui registros de medição
ALTER TABLE der_ce_contrato_medicoes.medicoes_contratos DISABLE TRIGGER tg_cme_tga_medicoes_contratos;
ALTER TABLE der_ce_contrato_medicoes.medicoes_contratos DISABLE TRIGGER tg_cme_tgb_medicoes_contratos;
  
DELETE FROM der_ce_contrato_medicoes.medicoes_contratos
 WHERE id IN (SELECT tab.id
                FROM der_ce_contrato_medicoes.medicoes_contratos tab
                JOIN controle_conservacao.medicoes         med ON med.id_old = tab.id);

ALTER TABLE der_ce_contrato_medicoes.medicoes_contratos ENABLE TRIGGER tg_cme_tga_medicoes_contratos;
ALTER TABLE der_ce_contrato_medicoes.medicoes_contratos ENABLE TRIGGER tg_cme_tgb_medicoes_contratos;

-- Exclui campos Temporario
ALTER TABLE controle_conservacao.medicoes 
  DROP COLUMN id_old;

-- ===============================================================================
-- FIM: Ações de encerramento da importação dos dados
-- ===============================================================================
 
-- =============================================================================
--
-- FIM: M I G R A Ç Ã O   d o s   D A D O S   E N T R E   S C H E M A S
--
-- =============================================================================