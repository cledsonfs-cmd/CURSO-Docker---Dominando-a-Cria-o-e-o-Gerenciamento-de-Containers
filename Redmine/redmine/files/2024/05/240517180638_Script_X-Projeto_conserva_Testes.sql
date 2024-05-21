-- =================================================================
--
-- AÇÔES COM CONCTRATOS de CONSERVA
--
-- =================================================================
   
-- ----------------------------------------------------------------
-- Insere um novo contrato de conserva
-- ----------------------------------------------------------------
INSERT INTO der_ce_contrato.contratos 
   (tipo, id_contratada, id_contratante,   id_status,      id_distrito, 
     id_calcula_imposto, id_aliquota_irrf, id_gestor,      nr_contrato_der,
     data_proposta,      data_assinatura,  data_publicacao,tipo_data_inicial, 
     prazo_inicial,      valor_original,   objeto) 
VALUES 
   (2, 100000538, 900001624, 1, 1, 2, 1, '99020015', '33332024', '02/04/2024', 
   '05/04/2024', '10/04/2024', 2, 100, 10000, '3o Contrato de Conserva para Teste');
   
-- Recupera Id do ultimo conrato Inserido
SELECT max(ctr.id) AS id_contrato_inserido -- 3098
  FROM der_ce_contrato.contratos  ctr;

 -- Visualiza dados relevante do ultimo contrato inserio
SELECT ctr.id, ctr.nr_contrato_der, ctr.id_natureza_contrato, 
       ctr.id_status, ctr.nr_ordem_servico  
  FROM der_ce_contrato.contratos ctr
 WHERE ctr.id IN (3099);

-- Visualiza lista de MUNICIPIOS ISS do contrato
SELECT cmi.* 
  FROM der_ce_contrato.contratos_municipios_iss cmi 
 WHERE cmi.id_contrato IN (3099);  

-- Vizualiza dados dos CREDORES do contrato
SELECT ccr.* 
  FROM der_ce_contrato.contratos_credores ccr 
 WHERE ccr.id_contrato IN (3099);

-- Seta id_aliquota_inss dos contratos incluido
UPDATE der_ce_contrato.contratos_credores 
   SET id_aliquota_inss = 1
 WHERE id_contrato IN (3099);
  
-- Seta id_aliquota_inss dos contratos incluido
UPDATE der_ce_contrato.contratos  
   SET id_status          = 2, -- Vigente
       nr_ordem_servico   = '3333/2024',
       data_ordem_servico = '15/04/2024',
       data_fim_execucao  = '15/04/2024'
 WHERE id IN (3099);
  
INSERT INTO controle_conservacao.contratos_fiscais
  (id_contrato,id_tipo_fiscal,id_fiscal, observacao) VALUES
(3100, 1, '99039995', 'Fiscal Presidente Cledson'),
(3100, 2, '99040000', 'Fiscal 1o Membro MAYCON'), 
(3100, 3, '99030499', 'Fiscal 2o Membro Robinho');
-- ----------------------------------------------------------------
-- Identificar contratos de Conserva vigentes
-- ----------------------------------------------------------------
SELECT ctr.id                        AS id_ctr,
       ctr.nr_contrato_der           AS contrato,  
       ctr.id_medicao_atual_conserva AS id_med_atual,
       med.nr_medicao,  
       med.id_status_fisico          AS id_fis, 
       sfi.descricao                 AS sta_fis,  
       med.id_status_financeiro      AS id_fin, 
       sfn.descricao                 AS sta_fin,
       med.id_periodo, 
       per.ano_mes                   AS periodo,       
       per.ativo
  FROM der_ce_contrato.contratos                      ctr
  LEFT JOIN controle_conservacao.medicoes                  med on med.id = ctr.id_medicao_atual_conserva
  LEFT JOIN controle_conservacao.status_medicao_fisico     sfi on sfi.id = med.id_status_fisico
  LEFT JOIN controle_conservacao.status_medicao_financeiro sfn on sfn.id = med.id_status_financeiro
  LEFT JOIN der_ce_medicao.periodos_medicoes_obras         per on per.id = med.id_periodo
 WHERE ctr.tipo      = 2 -- 2-Contrato de Conserva
   AND ctr.id_status = 2 -- 2-Status Vigente
   AND ctr.id        = 3098; -- id do Contrato

-- =================================================================
--
-- TRANSAÇÔES COM MEDICÃO de CONSERVA
--
-- =================================================================
   
-- --------------------------------------------------------
-- 1. A B R I R   M E D I C A O
-- --------------------------------------------------------
-- OBS: Ao Abrir Medição
--      1. TBI - Gerar Nr Medicao
--      2. APP - Setar Status fisico     -> 1-Aberto
--      3. APP - Status Financeiro -> 1-Ainda não encaminhado
--      4. TBI - registro na tabela: [pre_liquidações]
--      5. TAI - Setar campo: [id_medicao_atual_conserva] 
--               na tabela: [der_ce_contrato.contrato] = com id da medição aberta

INSERT INTO controle_conservacao.medicoes
(id_contrato, nr_medicao, data_inicio, data_fim, id_periodo, id_status_fisico,id_status_financeiro)
VALUES (2769,1,'01/01/2024','01/01/2024',280,1,1);

-- Recupera Id da ultima Medição Inserida
SELECT max(med.id) AS id_medicao_inserida
  FROM controle_conservacao.medicoes med;

-- --------------------------------------------------------
-- Recupera Dados da medição e Inserida 
-- --------------------------------------------------------
SELECT -- Relação de Ids de integração
       med.id                   AS med_id,     -- Medição
       med.id_contrato          AS med_id_ctr, -- Contrato
       med.id_pre_liquidacao    AS med_id_pre, -- Despacho
       med.id_despacho          AS med_id_dpc, -- Tramitacao
       med.id_despesa           AS med_id_des, -- DESPESA       
       -- Dados da Medição
       ctr.nr_contrato_der      AS ctr_nr,       
       med.nr_medicao           AS med_nr,
       med.nr_recibo            AS med_recibo,  
       med.id_status_fisico     AS stf_id,
       stf.descricao            AS stf_dsc,
       med.id_status_financeiro AS stn_id,
       stn.descricao            AS stn_dsc,
       med.nr_protocolo         AS med_protcolo,
       med.valor_medido         AS med_valor_pi,
       med.valor_processo       AS med_valor_processo,
       -- Dados Entidade DOC
       etd.id                   AS etd_id,
       etd.id_tipo_entidade     AS etd_id_tipo,
       etd.id_entidade          AS etd_id_med,
       etd.descricao            AS etd_descricao,
       -- Dados Pré-Liquidação
       pre.id                   AS pre_id,
       pre.id_tipo_origem       AS pre_id_tipo,
       pre.id_despesa_origem    AS pre_id_med,
       pre.id_despesa           AS pre_id_des,
       pre.valor_medido_pi      AS pre_valor_pi,
       pre.valor_adicional      AS pre_valor_adic,
       pre.valor_despesa        AS pre_valor_Desp,       
       -- Dados Despacho
       dpc.id                  AS dpc_id,
       dpc.nr_documento        AS dpc_protocolo,
       dpc.dth_criacao         AS dpc_dth_criacao,
       dpc.objeto              AS dpc_objeto,
       dpc.interessado         AS dpc_interessado,
       dpc.id_tipo_origem      AS dpc_id_tipo,
       dpc.id_origem           AS dpc_id_med, 
       dpc.id_tramitacao_atual AS dpc_id_tra,
       -- Dados da Tramitacao
       tra.id                  AS tra_id, 
       tra.nr_tramitacao       AS tra_nr,
       tra.id_status           AS tra_id_status,
       tra.id_assunto          AS tra_id_assunto,
       tra.id_modelo           AS tra_id_modelo,
       tra.id_documento        AS tra_id_doc,
       tra.id_setor_origem     AS tra_setor_ori,
       tra.id_setor_destino    AS tra_setor_des,
       -- Dados Despesa
       des.id                  AS des_id, 
       des.nr_protocolo        AS des_protcolo,
       des.ano_mes_referencia  AS des_periodo,
       des.valor_despesa       AS des_valor,
       des.id_status           AS des_id_status,
       des.objeto              AS des_objeto       
  FROM der_ce_contrato.contratos                      ctr
  JOIN controle_conservacao.medicoes                  med ON med.id = ctr.id_medicao_atual_conserva
  JOIN controle_conservacao.status_medicao_fisico     stf ON stf.id = med.id_status_fisico
  JOIN controle_conservacao.status_medicao_financeiro stn ON stn.id = med.id_status_financeiro
  LEFT JOIN der_ce_financeiro_imposto.pre_liquidacoes pre ON pre.id = med.id_pre_liquidacao
  LEFT JOIN der_ce_financeiro_despesa.despesas        des ON des.id = med.id_despesa
  LEFT JOIN controle_despachos.despachos              dpc ON dpc.id = med.id_despacho
  LEFT JOIN controle_despachos.tramitacoes            tra ON tra.id = dpc.id_tramitacao_atual 
  LEFT JOIN documento_digital.entidade_doc            etd ON med.id::text = etd.id_entidade AND etd.id_tipo_entidade = 122
 WHERE med.id = 2052; -- id da Medição inserida
  
-- ---------------------------------------------------------
-- 2. E X C L U I R   M E D I Ç Â O
-- ---------------------------------------------------------
-- OBS: Condições p/ Excluir uma Medição
--      1. TBU O Status Fisico deve obrigatoriamente ser: 1-ABERTO
--      2. APP - A Pre-Liquidação deve ser Desconectada da medição.
--      3. APP - Caso exista, [Medicao Fora Padrão] deve ser desconetada.

UPDATE controle_conservacao.medicoes 
   SET id_pre_liquidacao = NULL, -- Libera a preliquidação para ser excluida em cascata 
       id_fora_padrao    = NULL  -- Libera dados fora do padrão para ser excluida em cascata 
 WHERE id = 2066; -- id da Medição inserida
 
-- OBS: Ao Excluir a medição a TRIGGER BEFORE DELETE deve excluir em cascata:
--      1. Os registros na tabela: controle_conservacao.medicoes_historicos
--      2. Os registros na tabela: controle_conservacao.medicoes_ajustes
--      3. Os registros na tabela: controle_conservacao.medicoes_fiscais
--      4. Os registros na tabela: controle_conservacao.medicoes_fora_padrao
--      5. O registro na tabela: der_ce_financeiro_imposto.pre_liquidacoes 

DELETE -- Exclui a medição
  FROM controle_conservacao.medicoes 
 WHERE id = 2066; -- id da Medição inserida
   
-- ---------------------------------------------------------
-- 3. A P R E S E N T A R    M E D I Ç Â O   
-- ---------------------------------------------------------
-- OBS: 1.  APP - O Status Fisico deve estar 1-ABERTO
--      2.  APP - Se for apresentado como ZERO. 
--      2.1 APP -    campo: [obs_responsavel] é obrigatório
--      2,2 APP -    Setar status fisico 3-Aguardando Assinatura
--      3.  APP - Se for Apresentado como VALOR campo: 
--      3.1 APP -    [valor_medido] deve ser maior 0.0
--      3.2 APP -    Setar status fisico 2-Aguardando Validação
--      4.  TBU - Gerar valor do campo [nr_recibo]
 
-- Apresentar Medição ZERO
UPDATE controle_conservacao.medicoes 
   SET id_status_fisico = 3, -- 3-Aguardando Assinatura
       valor_medido     = 0,
       obs_responsavel  = 'Não houve execução' 
 WHERE id = 2019;  -- id da Medição Apresentada 
       
-- Apresentar Medição com Valor
UPDATE controle_conservacao.medicoes 
   SET id_status_fisico = 2 -- 2-Aguardando Validação
--       valor_medido     = 100
 WHERE id = 2052;  -- id da Medição Apresentada 
 
-- ---------------------------------------------------------
-- 4. V A L I D A R    M E D I Ç Â O
-- ---------------------------------------------------------
-- OBS: 1. APP - O Status Fisico deve estar 2-Aguardando Validação
--      2. APP - Gerar documentos digitais 
--      3. APP - Setar status fisico 2-Aguardando Validação

UPDATE controle_conservacao.medicoes 
   SET id_status_fisico = 3 -- 3-Aguardando Assinatura
 WHERE id = 2019;
  
-- ---------------------------------------------------------
-- 5. F I N A L I Z A R   A S S I N A T U R A S
-- ---------------------------------------------------------
-- OBS: 1.  APP - O Status Fisico deve estar 3-Aguardando Assinatura
--      2.  APP - Uma rotina batch deve detectar se todos documentos foram assinados
--      2.1 APP -     Se SIM: Setar status fisico 4-Aguardando Conferencia
-- ----------------------------------------------------------
-- Atualiza flag de assinatura para uma medição para Assinado
UPDATE documento_digital.documentos_digitais_x_assinadores tab
   SET id_assinado = 2 -- 2-Assinador Assinou
  FROM (SELECT dxa.id
          FROM documento_digital.documentos_digitais_x_assinadores dxa
          JOIN documento_digital.documentos_digitais doc ON doc.id = dxa.id_documento
          JOIN documento_digital.entidade_doc        etd ON etd.id = doc.id_entidade_doc
          JOIN documento_digital.tipo_documento      tdo ON tdo.id = doc.id_tipo_documento
         WHERE etd.id_tipo_entidade = 122    -- 122-Medicao Conserva
           AND etd.id_entidade      = '????' -- id_medicao
           AND dxa.id_assinado      = 1      -- '-Assinador Ainda Não Assinou
       ) qry
 WHERE tab.id = qry.id;

-- Altera Status da Medição
UPDATE controle_conservacao.medicoes 
   SET id_status_fisico = 4 -- 4-Aguardando Conferencia
 WHERE id = ?????;  -- id da Medição com assinaturas finalizadas
 
 -- Inclui historico da alteração do status
 INSERT INTO controle_conservacao.medicoes_historicos
(id_medicao, id_tipo_historico, matricula,  observacao)
VALUES (????, 8, 'SISTEMA', 'Teste manual 1a vez');

-- ---------------------------------------------------------
-- 5. R E A L I Z A R    C O N F E R E N C I A
-- ---------------------------------------------------------
-- OBS: 1. APP - O Status Fisico deve estar 4-Aguardando Conferencia
--      2. APP - A conferencia é feita em duas etapa
--      2.1. APP - Etapa 1: o campo: [doc_digitais_conferido] deve estar FALSE
--      2.2. APP - Etapa 2: o campo [doc_digitais_conferido] deve estar TRUE
        
-- ETAPA 1: APP - Botão p/ [Finalizar conferencia operacional]

-- SE um ou mais documentos foram rejeitados
UPDATE controle_conservacao.medicoes 
   SET doc_digitais_conferido = FALSE,
       id_status_fisico       = 3 -- 5-Aguardando Assinatura
 WHERE id = 2019; -- id da medição com conferencia operacional concluida

 -- SE todos documentos foram Aceitos 
UPDATE controle_conservacao.medicoes 
   SET doc_digitais_conferido = TRUE 
 WHERE id = 2019; -- id da medição com conferencia operacional concluida
 
-- ETAPA 2: APP - Botão p/ [Liberar para protocolar]
UPDATE controle_conservacao.medicoes 
   SET id_status_fisico = 5 -- 5-Aguardando PROTOCOLO
 WHERE id = 2052; -- id da medição Liberada para Protocolar
 
-- ---------------------------------------------------------
-- 7. R E G I S T R A R   P R O T O C O L O
-- ---------------------------------------------------------
-- OBS: 1. O Status Fisico deve estar 5-Aguardando PROTOCOLO
--      2. Após o registro do protocolo:
--      2.1 Se for Medição ZERO: Status Fisico = 7-Fechado
--      2.2 Se for Medição Valor: 
--      2.2.1 Status Fisico = 6-Aguardando ADMINISTRATIVO
--      2.2.2 Gera registro na tabela: [controle_despachos.despachos]

-- Medição de Valor
 UPDATE controle_conservacao.medicoes 
   SET id_status_fisico    = 6, -- 6-Aguardando ADMINISTRATIVO
       nr_protocolo        =  '8888888/2019',
       data_hora_protocolo = now()
 WHERE id = 2019; -- id da medição Protocolada
 
-- Medição de Valor
 UPDATE controle_conservacao.medicoes 
   SET id_status_fisico    = 7, -- 7-Fechada
       nr_protocolo        =  '8888888/2019',
       data_hora_protocolo = now()
 WHERE id = 2019; -- id da medição Protocolada
  
-- ---------------------------------------------------------
-- 8. E N C A M I N H A R   P A R A   F I N A C E I R O
-- ---------------------------------------------------------
-- OBS: 1. O Status Fisico deve estar 6-Aguardando ADMINISTRATIVO
--      2. Após Encaminhar:
--      2.1 Status Fisico     = 7-Fechado
--      2.2 Status Financeiro = 2-Aguardando Classificação
--      2.3 Gera registro na tabela: [der_ce_financeiro_despesa.despesas]

 UPDATE controle_conservacao.medicoes 
   SET id_status_fisico     = 7, -- 7-FECHADO
       id_status_financeiro = 2  -- 2-Aguardando Classificação
 WHERE id = 2019; -- id da medição Encaminhada p/ financeiro e fechada
 
-- ---------------------------------------------------------
-- 9. REJEITAR MEDICAO (Fiscal que rejeita Na tela de Validação)
-- ---------------------------------------------------------
-- OBS: 1. APP - O Status Fisico deve estar 2-Aguardando Validação
--      2. APP - Deve solicitar motivo e registrar no historico
--      3. APP - Setar status fisico 1-ABERTA
 
 UPDATE controle_conservacao.medicoes 
   SET id_status_fisico     = 1 -- 1-ABERTA
 WHERE id = 2019; -- id da medição que será rejeitada pelo FISCAL
 
-- ---------------------------------------------------------
-- 10. REABRIR MEDICAO (0 FISCAL que reabre Na tela de Validação)
-- ---------------------------------------------------------
-- OBS: 1. APP - O Status Fisico deve ser:
--         3-AAS-Aguardando Assinatura
--         2-AVA-Aguardando Validação 
-- OBS: 2. A Medição pode ser Reabeta para:
--      2.1 O Fiscal -> De 3-AAS          Para 2-AVA (Não Requer Motivo)      
--      2.2 A Empresa-> De 3-AAS ou 2-AVA Para 1-ABE (Requer motivo p/ historico)
 
UPDATE controle_conservacao.medicoes 
   SET id_status_fisico  = 1 -- 1-ABERTA
 WHERE id = 2019; -- id da medição que será rejeitada pelo FISCAL

-- ---------------------------------------------------------
-- 11. REABRIR MEDICAO (A GEMED que reabre na Tela de Reabertura)
-- ---------------------------------------------------------
-- OBS: 1. APP - O Status Fisico deve ser:
--         6-AAD-Aguardando Administrativo
--         5-APT-Aguardando Protocolo
--         4-ACO-Aguardando Conferencia
--         3-AAS-Aguardando Assinatura 
-- OBS: 2. A Medição pode ser Reabeta para:
--      2.1 O Fiscal  -> Altera Status Para 2-AVA (Não Requer Motivo)      
--      2.2 A Empresa -> Altera Status Para 1-ABE (Requer motivo p/ historico)
--      2.3 A Operador-> Ainda Falta Definições ?????