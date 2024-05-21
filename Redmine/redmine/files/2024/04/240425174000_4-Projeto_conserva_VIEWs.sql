-- =============================================================================
--
-- INICIO: C R I A Ç Â O   d a s   V I E W S 
--
-- =============================================================================

-- =============================================================================
-- VIEW....: controle_conservacao.vw_contratos
-- CLASSE..: controle_conservacao.VoContrato.java
-- OBJETIVO: Retorna lista de contrato de conserva
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_contratos AS
SELECT
  ctr.id,
  -- Identificação do Contrato
  ctr.nr_contrato_der AS nr_contrato,
  ctr.objeto,
  stc.descricao       AS status,
  ges.nome_completo   AS gestor,
  ctd.nome_fantasia   AS contratada,
  -- Controle de Vigencia
  CASE ctr.tipo_data_inicial
       WHEN 1 THEN ctr.data_publicacao
       WHEN 2 THEN ctr.data_assinatura
       WHEN 3 THEN ctr.data_ordem_servico
              ELSE NULL
  END               AS data_inicio_vigencia,
  ctr.data_fim_vigencia,
  -- Valores Globais do Contrato
  ctr.valor_original,
  ctr.total_aditivo, 
  ctr.valor_pi,      
  ctr.total_reajuste,
  ctr.valor_atual,
  vpc.total_medido_pi,  
  vpc.saldo_a_medir,
  ctr.id_distrito,
  dop.nome as distrito_operacional
FROM der_ce_contrato.contratos                  ctr
JOIN der_ce_contrato.status_contrato            stc ON stc.id = ctr.id_status
JOIN der_ce_coorporativo.distritos_operacionais dop ON dop.id = ctr.id_distrito
JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
JOIN der_ce_coorporativo.vw_funcionario         ges ON ges.id = ctr.id_gestor
JOIN der_ce_contrato.vw_valores_por_contrato    vpc ON ctr.id = vpc.id
WHERE ctr.tipo = 2; -- 2-Contrato de conserva

--DROP VIEW controle_conservacao.vw_medicoes ;
-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes
-- CLASSE..: controle_conservacao.VoMedicao.java
-- OBJETIVO: Retorna lista de Medições de contratos de conserva
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes AS
SELECT 
  med.id, 
  --Dados do Contrato
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctd.nome_fantasia AS contratada, 
  fis.nome_completo AS fiscal, 
  dop.nome          AS distrito,
  --Dados da medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes   AS periodo,
  -- Status Fisico da Medição
  sfs.id        AS status_fisico_id,
  sfs.cor       AS status_fisico_cor,
  sfs.sigla     AS status_fisico_sigla,
  sfs.descricao AS status_fisico_descricao,
  -- Dados do Protocolo
  med.nr_protocolo,
  med.data_hora_protocolo,
  -- Status Fisico da Medição
  sfn.id        AS status_financeiro_id,
  sfn.cor       AS status_financeiro_cor,
  sfn.sigla     AS status_financeiro_sigla,
  sfn.descricao AS status_financeiro_descricao,
  med.doc_digitais_conferido
FROM controle_conservacao.medicoes          med
JOIN der_ce_medicao.periodos_medicoes_obras per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos              ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada      ctd ON ctd.id = ctr.id_contratada 
JOIN der_ce_coorporativo.distritos_operacionais              dop ON dop.id = ctr.id_distrito 
JOIN controle_conservacao.status_medicao_fisico     sfs ON sfs.id = med.id_status_fisico
JOIN controle_conservacao.status_medicao_financeiro sfn ON sfn.id = med.id_status_financeiro
LEFT JOIN controle_conservacao.medicoes_fiscais     mcf ON med.id = mcf.id_medicao 
                                                                AND mcf.id_tipo_fiscal = 1 -- 1_presidente da Comissão                                                                
LEFT JOIN der_ce_coorporativo.vw_funcionario     fis ON fis.matricula = mcf.id_fiscal;
  
-- DROP  VIEW controle_conservacao.vw_medicoes_a_abrir;
-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_a_abrir
-- CLASSE..: controle_conservacao.VoMedicaoAAbrir.java
-- OBJETIVO: Retorna lista de contrato de conserva em condições de abrir Medição
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_a_abrir AS
SELECT 
  --Dados do Contrato
  ctr.id, 
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctr.data_fim_vigencia,
  stc.descricao                  AS status_contrato,
  ctd.nome_fantansia             AS contratada,  
  --Valores do contrato
  ctr.valor_pi                   AS valor_pi,
  COALESCE(tmd.total_medido,0)   AS total_medido,
  ctr.valor_pi - ctr.saldo_bloqueado -
  COALESCE(tmd.total_medido,0)   AS saldo_a_medir,
  -- Situação da Abertura
  sam.id        AS situacao_abertura_id,     -- Indicativo de abertura de medição  
  sam.cor       AS situacao_abertura_cor,
  sam.descricao AS situacao_abertura_descricao,  
  umd.situacao_abertura_detalhes, -- Mensagem equivalente a cada indicador  
  -- Nr. da Medição a Ser Aberta
  CASE WHEN umd.id_situacao_abertura = 1 
       THEN umd.nr_ultima_medicao_aberta  
       ELSE umd.nr_medicao_a_ser_aberta
  END AS nr_medicao_a_ser_aberta,
  --Dados da última medição registrada
  umd.nr_protocolo,  -- Nr do protocolo da Medição Anterior
  umd.data_hora_protocolo, 
  umd.status_fisico,
  CASE WHEN umd.id_situacao_abertura = 1 THEN umd.data_inicio_medicao       -- 1-Med.Aberta no periodo Ativo
       WHEN umd.id_situacao_abertura = 2 THEN umd.data_inicio_periodo_atual -- 2-Pode Abrir Medição Padrão
       WHEN umd.id_situacao_abertura = 3 THEN umd.data_inicio_periodo_refer -- 3-Pode Abrir Fora Padrão
       WHEN umd.id_situacao_abertura = 4 THEN NULL::date                    -- 4-Impossivel Abrir
  END  AS   periodo_data_inicio,
  CASE WHEN umd.id_situacao_abertura = 1 THEN umd.data_fim_medicao          -- 1-Med.Aberta no periodo Ativo
       WHEN umd.id_situacao_abertura = 2 THEN umd.data_fim_periodo_atual    -- 2-Pode Abrir Medição Padrão
       WHEN umd.id_situacao_abertura = 3 THEN umd.data_fim_periodo_refer    -- 3-Pode Abrir Fora Padrão
       WHEN umd.id_situacao_abertura = 4 THEN NULL::date                    -- 4-Impossivel Abrir
  END  AS   periodo_data_fim,
  umd.id_periodo_anterior,
  umd.id_periodo_referencia,
  umd.id_periodo_atual, 
  umd.periodo_anterior,      -- ANO_MES do periodo da Ultima Medição registradas
  umd.periodo_referencia,    -- ANO_MES do periodo de refer. Medições Fora Padrão
  umd.periodo_atual,         -- ANO_MES do periodo Ativo p/ Medições Padrões
  umd.intervalo_periodos    -- Qtd de Periodos entre Periodo_Atual e Periodo_Anterior
FROM         der_ce_contrato.contratos              ctr
  INNER JOIN der_ce_contrato.status_contrato        stc ON stc.id = ctr.id_status
  INNER JOIN der_ce_coorporativo.pessoas_juridicas  ctd ON ctd.id_pessoa = ctr.id_contratada
  LEFT  JOIN (-- -----------------------------------------------------------
              -- Recupera dados da ultima Medição
              SELECT 
                ctr.id                         AS id_contrato, 
                COALESCE(med.nr_medicao,0)     AS nr_ultima_medicao_aberta,   
                COALESCE(med.nr_medicao,0) + 1 AS nr_medicao_a_ser_aberta,      
                smf.descricao                  AS status_fisico,
                med.nr_protocolo,
                med.data_hora_protocolo,
                prf.data_inicio_periodo::date  AS data_inicio_periodo_refer, 
                prf.data_fim_periodo::date     AS data_fim_periodo_refer,
                pat.data_inicio_periodo::date  AS data_inicio_periodo_atual, 
                pat.data_fim_periodo::date     AS data_fim_periodo_atual,
                med.data_inicio::date          AS data_inicio_medicao, 
                med.data_fim::date             AS data_fim_medicao,   
                pan.id                         AS id_periodo_anterior,
                prf.id                         AS id_periodo_referencia,
                pat.id                         AS id_periodo_atual,
               (SUBSTRING(pan.ano_mes, 5, 2) || '-') || 
                SUBSTRING(pan.ano_mes, 1, 4)   AS periodo_anterior,
               (SUBSTRING(prf.ano_mes, 5, 2) || '-') || 
                SUBSTRING(prf.ano_mes, 1, 4)   AS periodo_referencia,
               (SUBSTRING(pat.ano_mes, 5, 2) || '-') || 
                SUBSTRING(pat.ano_mes, 1, 4)   AS periodo_atual,
                -- Calcula Intervalo entre periodos: ((anoAtual-anoAnter)*12)+(mesAtual-mesAnter)
               ((LEFT(pat.ano_mes,4)::INTEGER - LEFT(pan.ano_mes,4)::INTEGER) * 12) +
               (RIGHT(pat.ano_mes,2)::INTEGER -RIGHT(pan.ano_mes,2)::INTEGER) 
                                               AS intervalo_periodos,
                CASE WHEN pan.id = pat.id           THEN 1 -- SE já existir uma medição no periodo vigente ENTAO 1-Med.Aberta
                     WHEN ctr.id_status        <> 2 THEN 4 -- SE Status do contrato Não for 2-Vigente      ENTAO 4-Impossivel Abrir
                     WHEN med.id_status_fisico <> 7 THEN 4 -- SE Medição Anterior não tiver sido fechada   ENTAO 4-Impossivel Abrir
                     WHEN (((LEFT(pat.ano_mes,4)::INTEGER - LEFT(pan.ano_mes,4)::INTEGER) * 12) +
                           (RIGHT(pat.ano_mes,2)::INTEGER -RIGHT(pan.ano_mes,2)::INTEGER)) > 1 
                     THEN 3                                -- Se estiver a mais de um periodo sem abrir    ENTAO 3-Pode Abrir Fora Padrão
                     ELSE 2                                --                                              SENAO 2-Pode Abrir Medição Padrão
                END                            AS id_situacao_abertura,
                CASE WHEN pan.id = pat.id           THEN 'Medição Aberta no Período Vigênte'
                     WHEN ctr.id_status        <> 2 THEN 'Contrato Não Está Vigênte. (Status = ' || stc.descricao || ')' 
                     WHEN med.id_status_fisico <> 7 THEN 'Medição Anterior Ainda Não Foi Fechada. (Status = ' || stm.descricao || ')'
                     WHEN (((LEFT(pat.ano_mes,4)::INTEGER - LEFT(pan.ano_mes,4)::INTEGER) * 12) +
                           (RIGHT(pat.ano_mes,2)::INTEGER - RIGHT(pan.ano_mes,2)::INTEGER)) > 1 
                                                    THEN 'Medição Referente a Outro Periodo'
                                                    ELSE 'Medição a ser aberta no periodo Vigente.'
                END AS situacao_abertura_detalhes
              FROM         der_ce_contrato.contratos                  ctr
                INNER JOIN der_ce_contrato.status_contrato            stc ON stc.id = ctr.id_status
                LEFT  JOIN controle_conservacao.medicoes              med ON med.id = ctr.id_medicao_atual_conserva
                LEFT  JOIN controle_conservacao.status_medicao_fisico stm ON stm.id = med.id_status_fisico
                LEFT  JOIN der_ce_medicao.periodos_medicoes_obras     pan ON pan.id = med.id_periodo -- Periodo Da Ultima Medição
                LEFT  JOIN der_ce_medicao.periodos_medicoes_obras     prf ON prf.id = 
                           der_ce_medicao_periodo.fn_per_retorna_id_proximo_periodo_medicao(med.id_periodo) -- Periodo seguinte a Ultima Medição
                LEFT  JOIN controle_conservacao.status_medicao_fisico smf ON smf.id = med.id_status_fisico
                          ,der_ce_medicao.periodos_medicoes_obras     pat -- Periodo Atual
              WHERE pat.ativo          -- Periodo Atual Ativo
                AND ctr.tipo      = 2  -- 2-Contrato de conserva
                AND ctr.id_status < 5 -- 5-Concluido com divida 6-Rescindido 7-encerrado
  ) umd ON ctr.id = umd.id_contrato
  LEFT  JOIN (-- Calcula Total Medido por contrato
              SELECT mdc.id_contrato, 
                     sum(mdc.valor_medido + mdc.valor_ref_glosa) AS total_medido
                FROM controle_conservacao.medicoes mdc
	        GROUP BY mdc.id_contrato
             ) tmd ON ctr.id = tmd.id_contrato
LEFT JOIN controle_conservacao.situacao_abertura_medicao sam ON sam.id = umd.id_situacao_abertura
WHERE ctr.tipo      = 2  -- 2-Contrato de conserva
  AND ctr.id_status < 5; -- Fica Fora: 5-Concluido com divida 6-Rescindido 7-encerrado
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_a_abrir  IS 'Lista dos contratos de conserva que ainda não tenha sido concluido/rescindido ou encerrado, com as ultimas medições registradas.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.nr_contrato_der             IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.objeto                      IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.data_fim_vigencia           IS 'Data prevista de fim da vigencia do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.status_contrato             IS 'Status Atual do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.contratada                  IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.valor_pi                    IS 'Valor PI = Origimal + Aditivos referente ao contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.total_medido                IS 'Valor Total Já executado do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.saldo_a_medir               IS 'Saldo a Medir do Contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.situacao_abertura_id        IS 'Id da situação de abertura. Ver tabela: Situação Abertura.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.situacao_abertura_cor       IS 'Cor utilizada para cada situação de abertura.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.situacao_abertura_descricao IS '1.Med.Ja Aberta 2.Abrir Padrão 3.Abrir Fora Padrão 4. Impossivel Abrir.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.situacao_abertura_detalhes  IS 'Informações adicionais sobre a Situação da Aberura.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.nr_medicao_a_ser_aberta     IS 'Numero da medição que poderá ser aberta.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.nr_protocolo                IS 'Número do protocolo da ultima medição registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.data_hora_protocolo         IS 'Data e Hora em que o protocolo da medição foi registrado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.status_fisico               IS 'Stutus fisico da ultima medição registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.periodo_data_inicio         IS 'Data de inicio da ultima medição registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.periodo_data_fim            IS 'Data de Fim da ultima medição registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.id_periodo_anterior         IS 'Id do periodo em que a ultima medição foi registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.id_periodo_referencia       IS 'Id do periodo em que a medição fora padrão se refere.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.id_periodo_atual            IS 'Id do Periodo ativo que as medições foram efetivamente aberta.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.periodo_anterior            IS 'Mes ano do periodo em que a ultima medição foi registrada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.periodo_anterior            IS 'Mes ano do periodo em que a medição fora padrão se refere.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.periodo_anterior            IS 'Mes ano do periodo em que as medições foram efetivamente aberta.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_a_abrir.intervalo_periodos          IS 'Qtd de Periodos entre o anterior e o atual';

--DROP VIEW controle_conservacao.vw_medicoes_aberta;
-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_aberta
-- CLASSE..: controle_conservacao.VoMedicaoAberta.java
-- OBJETIVO: Retorna lista de Medições com status Aberta
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_aberta AS
SELECT 
  med.id, 
  --Dados do Contrato
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctr.data_fim_vigencia,
  ctd.cnpj          AS cnpj_contratada,
  ctd.nome_fantasia AS contratada,  
  --Valores do contrato
  ctr.valor_pi                 AS valor_pi,
  COALESCE(tmd.total_medido,0) AS total_medido,
  ctr.valor_pi - ctr.saldo_bloqueado -
  COALESCE(tmd.total_medido,0) AS saldo_a_medir,
  --Dados da última medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes     AS periodo,
  CASE WHEN med.id_fora_padrao ISNULL 
       THEN per.data_fim_apresentacao 
       ELSE mfp.apresentar_ate 
  END AS apresentar_ate,
  med.valor_medido,
  med.fator_reajuste,
  med.valor_reajuste,
  med.obs_responsavel
FROM controle_conservacao.medicoes med
JOIN der_ce_medicao.periodos_medicoes_obras per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos              ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada      ctd ON ctd.id = ctr.id_contratada
LEFT JOIN controle_conservacao.medicoes_fora_padrao mfp ON mfp.id = med.id_fora_padrao
LEFT JOIN (-- Calcula Total Medido
           SELECT mdc.id_contrato, 
                  sum(mdc.valor_medido + mdc.valor_ref_glosa) AS total_medido
             FROM controle_conservacao.medicoes mdc
	     GROUP BY mdc.id_contrato
          ) tmd ON ctr.id = tmd.id_contrato
WHERE med.id_status_fisico = 1; -- 1-Medição Aberta
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_aberta IS 'Lista de Medições Abertas Aguardando Apresentação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.nr_contrato_der   IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.objeto            IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.data_fim_vigencia IS 'Data prevista de fim da vigencia do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.cnpj_contratada   IS 'CNPJ da Emmpresa contratada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.contratada        IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.valor_pi          IS 'Valor PI = Origimal + Aditivos referente ao contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.total_medido      IS 'Valor Total Já executado do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.saldo_a_medir     IS 'Saldo a Medir do Contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.nr_medicao        IS 'Nr. da medição que será apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.data_inicio       IS 'Data de inicio do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.data_fim          IS 'Data de término do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.periodo           IS 'Periodo AAAAMM no qual a medição será apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aberta.apresentar_ate    IS 'Data Limite de Apresentação da Medição.';

--DROP VIEW controle_conservacao.vw_medicoes_aguardando_validacao;
-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_aguardando_validacao
-- CLASSE..: controle_conservacao.VoMedicaoAguardandoValidacao.java
-- OBJETIVO: Retorna lista de Medições com status Aguardando Validação
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_aguardando_validacao AS
SELECT 
  --Dados do Contrato
  med.id, 
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctr.data_fim_vigencia,
  ctd.nome_fantasia AS contratada, 
  fis.matricula     AS matricula_fiscal,
  fis.nome_completo AS nome_fiscal, 
  --Dados da última medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes as periodo,
  CASE WHEN med.id_fora_padrao ISNULL 
       THEN per.data_fim_apresentacao 
       ELSE mfp.apresentar_ate 
  END AS validar_ate,
  med.valor_medido,  
  -- Status Fisico da Medição
  sfs.id        AS status_fisico_id,
  sfs.cor       AS status_fisico_cor,
  sfs.sigla     AS status_fisico_sigla,
  sfs.descricao AS status_fisico_descricao
FROM controle_conservacao.medicoes              med
JOIN controle_conservacao.status_medicao_fisico sfs ON sfs.id = med.id_status_fisico
JOIN der_ce_medicao.periodos_medicoes_obras     per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos                  ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
JOIN controle_conservacao.medicoes_fiscais      mcf ON med.id = mcf.id_medicao 
                                                   AND mcf.id_tipo_fiscal = 1 -- 1_presidente da Comissão
JOIN der_ce_coorporativo.vw_funcionario         fis ON fis.matricula = mcf.id_fiscal      
LEFT JOIN controle_conservacao.medicoes_fora_padrao mfp ON mfp.id = med.id_fora_padrao                                                 
WHERE med.id_status_fisico IN (2,3); -- 2-Aguardando Validação ou 3-Aguardando Assinatura
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_aguardando_validacao IS 'Lista de Medições Abertas Aguardando Apresentação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.nr_contrato_der     IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.objeto              IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.data_fim_vigencia   IS 'Data prevista de fim da vigencia do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.contratada          IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.matricula_fiscal    IS '.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.nome_fiscal         IS '.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.nr_medicao          IS 'Nr. da medição que foi apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.data_inicio         IS 'Data de inicio do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.data_fim            IS 'Data de término do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.periodo             IS 'Periodo AAAAMM no qual a medição foi apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.validar_ate         IS 'Data Limite de Validação da Medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_validacao.valor_medido        IS 'Valor medido a ser informaado pelo usuário.';

-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_aguardando_conferencia
-- CLASSE..: controle_conservacao.VoMedicaoAguardandoConferencia
-- OBJETIVO: Retorna lista de Medições com status Aguardando Conferencia
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_aguardando_conferencia AS
SELECT 
  --Dados do Contrato
  med.id, 
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctd.nome_fantasia AS contratada,  
  --Dados da última medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes AS periodo,
  med.valor_medido,
  med.doc_digitais_conferido,
  pce.id        AS id_ponto_entidade,
  pce.id_status AS id_status_ponto_entidade 
FROM controle_conservacao.medicoes                  med
JOIN der_ce_medicao.periodos_medicoes_obras         per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos                      ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada              ctd ON ctd.id = ctr.id_contratada
LEFT JOIN documento_digital.entidade_doc            etd ON etd.id_entidade       = med.id::text 
                                                       AND etd.id_tipo_entidade  = 122   -- 122 - Medição da Conserva Rodoviaris
LEFT JOIN documento_digital.ponto_controle_entidade pce ON pce.id_entidade_doc   = etd.id 
                                                       AND pce.id_ponto_controle = 12235 -- 12235 - Antes de Protocolar Medição                                                   
WHERE med.id_status_fisico = 4; -- 4-Aguardando Conferencia
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_aguardando_conferencia IS 'Lista de Medições Abertas Aguardando Conferencia.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.nr_contrato_der     IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.objeto              IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.contratada          IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.nr_medicao          IS 'Nr. da medição que foi apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.data_inicio         IS 'Data de inicio do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.data_fim            IS 'Data de término do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.periodo             IS 'Periodo AAAAMM no qual a medição foi apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.valor_medido        IS 'Valor medido a ser informaado pelo usuário.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.doc_digitais_conferido   IS 'Se True Indica que pode ser liberado p/ protocolar.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.id_ponto_entidade        IS 'Id Ponto controle (1223-Antes de Protocolar) do Tipo Entidade: (122-Medição da Conserva) da Medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_conferencia.id_status_ponto_entidade IS 'Id Status Ponto Controle da Entidade. Ver tabela: Status_ponto_controle';

-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_aguardando_protocolo
-- CLASSE..: controle_conservacao.VoMedicaoAguardandoProtocolo
-- OBJETIVO: Retorna lista de Medições com status Aguardando Protocolar
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_aguardando_protocolo AS
SELECT 
  --Dados do Contrato
  med.id, 
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctd.nome_fantasia AS contratada,  
  --Dados da última medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes as periodo,
  med.valor_medido
FROM controle_conservacao.medicoes              med
JOIN der_ce_medicao.periodos_medicoes_obras     per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos                  ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
WHERE med.id_status_fisico = 5; -- 5-Aguardando Protocolo
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_aguardando_protocolo IS 'Lista de Medições Abertas Aguardando Protocolo.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.nr_contrato_der     IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.objeto              IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.contratada          IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.nr_medicao          IS 'Nr. da medição que foi apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.data_inicio         IS 'Data de inicio do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.data_fim            IS 'Data de término do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.periodo             IS 'Periodo AAAAMM no qual a medição foi apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_protocolo.valor_medido        IS 'Valor medido a ser informaado pelo usuário.';

-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_aguardando_administrativo
-- CLASSE..: controle_conservacao.VoMedicaoAguardandoAdministrativo
-- OBJETIVO: Retorna lista de Medições com status Aguardando Administrativo
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_aguardando_administrativo AS
SELECT 
  --Dados do Contrato
  med.id, 
  med.id_contrato,
  med.id_pre_liquidacao,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctd.nome_fantasia AS contratada,  
  --Dados da última medição
  med.nr_medicao,
  med.data_inicio,
  med.data_fim,
  per.ano_mes as periodo,
  -- Valores da medição
  med.valor_medido,
  med.valor_ref_glosa,
  med.valor_reajuste,
  med.valor_ajuste_contratual,
  med.valor_processo,
  med.descricao_glosa,
  med.descricao_ajuste_contratual,  
  -- dados do protocolo
  med.nr_protocolo,
  med.data_hora_protocolo
FROM controle_conservacao.medicoes              med
JOIN der_ce_medicao.periodos_medicoes_obras     per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos                  ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
WHERE med.id_status_fisico = 6; -- 6-Aguardando Administrativo
-- ------------------------------------------------------------------------------  
COMMENT ON   VIEW controle_conservacao.vw_medicoes_aguardando_administrativo IS 'Lista de Medições Abertas Aguardando Conferencia.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.nr_contrato_der     IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.objeto              IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.contratada          IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.nr_medicao          IS 'Nr. da medição que foi apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.data_inicio         IS 'Data de inicio do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.data_fim            IS 'Data de término do período da medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.periodo             IS 'Periodo AAAAMM no qual a medição foi apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_aguardando_administrativo.valor_medido        IS 'Valor medido a ser informaado pelo usuário.';

-- =============================================================================
-- VIEW....: controle_conservacao.vw_medicoes_prorrogaveis
-- CLASSE..: controle_conservacao.VoMedicaoProrrogavel.java
-- OBJETIVO: Retorna lista de Medições que permitem prorrogação de apresentação/validação
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_medicoes_prorrogaveis AS
SELECT 
  med.id, 
  --Dados do Contrato
  med.id_contrato,
  ctr.nr_contrato_der, 
  ctr.objeto,
  ctd.nome_fantasia AS contratada,  
  med.nr_medicao,
  -- Status Fisico da Medição
  sfs.cor           AS status_fisico_cor,
  sfs.sigla         AS status_fisico_sigla,
  sfs.descricao     AS status_fisico_descricao,
  per.ano_mes       AS periodo,
  -- Datas Limites atuais
  CASE WHEN med.id_fora_padrao ISNULL 
       THEN per.data_apresentacao_rascunho  
       ELSE mfp.apresentar_ate 
  END               AS apresentar_ate,
  CASE WHEN med.id_fora_padrao ISNULL 
       THEN per.data_fim_apresentacao
       ELSE mfp.validar_ate 
  END               AS validar_ate
FROM controle_conservacao.medicoes              med
JOIN controle_conservacao.status_medicao_fisico sfs ON sfs.id = med.id_status_fisico
JOIN der_ce_medicao.periodos_medicoes_obras     per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos                  ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
LEFT JOIN controle_conservacao.medicoes_fora_padrao mfp ON mfp.id = med.id_fora_padrao
WHERE med.id_status_fisico IN (1,2); -- 1-Aberta 2-Aguardando Validação
-- ------------------------------------------------------------------------------  
COMMENT ON  VIEW controle_conservacao.vw_medicoes_prorrogaveis  IS 'Lista de Medições que permitem prorrogação de apresentação/validação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.nr_contrato_der IS 'Numero do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.objeto          IS 'Objeto do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.contratada      IS 'Empresa contratada do contrato de conservação.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.nr_medicao      IS 'Nr. da medição que será apresentada.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.periodo         IS 'Periodo AAAAMM no qual a medição será apresentado.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.apresentar_ate  IS 'Data Limite de Apresentação da Medição.';
COMMENT ON COLUMN controle_conservacao.vw_medicoes_prorrogaveis.validar_ate     IS 'Data Limite de Validação da Medição.';
 
-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicao.java 
-- OBJETIVO: Compor a ficha de Medição dos Contratos de conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao AS 
SELECT 
  med.id,
  med.id_contrato,
  -- dados do Contrato tipo TIPO 2-CONSERVA
  ctr.nr_contrato_der,
  ctr.objeto,
  ctd.nome_fantasia                  AS contratada,
  COALESCE(ges.matricula      ,' ')  AS gestor_matricula,
  COALESCE(ges.nome_referencia,' ')  AS gestor_nome,
  COALESCE(fis.matricula      ,' ')  AS fiscal_matricula,
  COALESCE(fis.nome_referencia,' ')  AS fiscal_nome,
  dop.nome                           AS distrito,
  -- dados da Medição
  med.nr_medicao,
  to_char(med.data_inicio,'dd/MM/yyyy') AS data_inicio,
  to_char(med.data_fim,   'dd/MM/yyyy') AS data_fim, 
  SUBSTRING(per.ano_mes,5,2) || '-' || 
  SUBSTRING(per.ano_mes,1,4)            AS periodo,  
  -- Status Fisico da Medição
  sfs.cor       AS status_fisico_cor,
  sfs.sigla     AS status_fisico_sigla,
  sfs.descricao AS status_fisico_descricao,
  -- Dados do Protocolo da Medição
  med.nr_protocolo,
  to_char(med.data_hora_protocolo, 'dd/MM/yyyy HH24:MI') AS data_hora_protocolo,
  -- Status Fisico da Medição
  sfn.cor       AS status_financeiro_cor,
  sfn.sigla     AS status_financeiro_sigla,
  sfn.descricao AS status_financeiro_descricao,
  CASE WHEN med.doc_digitais_conferido
       THEN 'Sim' ELSE 'Não'
  END           AS doc_digitais_conferido,  
  -- Valores da Medição
  med.valor_medido,
  med.valor_ref_glosa,
  med.fator_reajuste,
  med.valor_reajuste,
  med.valor_ajuste_contratual, 
  med.valor_processo,  
  -- Informações  complementares 
  med.descricao_glosa                AS descricao_glosa,
  med.descricao_ajuste_contratual    AS descricao_ajuste,
  med.obs_responsavel,
  -- Valores Financeiros da Medição
  COALESCE(des.total_empenhado,0) AS valor_empenhado,
  COALESCE(des.total_pago     ,0) AS valor_pago,
  COALESCE(med.valor_processo ,0) -
  COALESCE(des.total_empenhado,0) AS valor_a_empenhar,
  COALESCE(med.valor_processo ,0) -
  COALESCE(des.total_pago     ,0) AS valor_a_pagar
FROM controle_conservacao.medicoes med
JOIN der_ce_medicao.periodos_medicoes_obras per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos              ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada      ctd ON ctd.id = ctr.id_contratada
JOIN der_ce_coorporativo.distritos_operacionais              dop ON dop.id = ctr.id_distrito 
JOIN controle_conservacao.status_medicao_fisico     sfs ON sfs.id = med.id_status_fisico
JOIN controle_conservacao.status_medicao_financeiro sfn ON sfn.id = med.id_status_financeiro
LEFT JOIN der_ce_coorporativo.vw_funcionario                 ges ON ges.id = ctr.id_gestor
LEFT JOIN der_ce_financeiro_despesa.despesas                 des ON des.id = med.id_despesa
LEFT JOIN controle_conservacao.medicoes_fiscais     mcf ON med.id = mcf.id_medicao AND mcf.id_tipo_fiscal = 1 -- 1_presidente da Comissão                                                                
LEFT JOIN der_ce_coorporativo.vw_funcionario                 fis ON fis.matricula = mcf.id_fiscal;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_ajustes
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoAjustes.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_ajustes AS 
SELECT 
  mca.id,
  mca.id_medicao,
  mca.autorizado_por,
  mca.motivo,
  mca.data_ajuste,
  mca.valor_anterior,
  mca.valor_ajuste,
  mca.novo_valor
FROM controle_conservacao.medicoes_ajustes mca;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_historicos
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoHistoricos.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_historicos AS 
SELECT 
  mch.id,
  mch.id_medicao,
  mch.matricula  AS usuario,
  to_char(mch.data_hora,'dd/mm/yyyy HH24:MI') AS data_hora,
  thm.descricao  AS tipo,
  mch.observacao AS complemento
FROM controle_conservacao.medicoes_historicos     mch 
JOIN controle_conservacao.tipo_historico_medicoes thm ON thm.id = mch.id_tipo_historico
ORDER BY mch.id;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_municipios_iss
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoMunicipiosIss.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_municipios_iss AS
SELECT plm.id,
       pre.id_despesa_origem AS id_medicao,
       plm.id_municipio_iss  AS municipio_codigo,
       cid.nome              AS municipio_nome,
       cid.uf                AS municipio_uf,
       plm.perc_part_mun,
       plm.perc_al_iss,
       plm.perc_bc_iss,
       plm.valor_medido_pi,
       plm.valor_adicional,
       plm.valor_despesa,
       plm.observacao
FROM der_ce_financeiro_imposto.pre_liquidacoes                   pre
JOIN der_ce_financeiro_imposto.pre_liquidacoes_por_municipio_iss plm ON pre.id = plm.id_pre_liquidacao
JOIN der_ce_coorporativo.cidades                                 cid ON cid.id = plm.id_municipio_iss
WHERE pre.id_tipo_origem = 2; -- 2-Tipo Origem = Medição Conserva

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_servicos_inss
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoServicosInss.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_servicos_inss AS
SELECT pls.id,
       pre.id_despesa_origem AS id_medicao,
       pls.id_servico_inss   AS servico_codigo,
       bcs.descricao         AS servico_descricao,
       pls.perc_part_ser,
       pls.perc_bc_inss,
       pls.valor_medido_pi,
       pls.valor_adicional,
       pls.valor_despesa,
       pls.observacao
FROM der_ce_financeiro_imposto.pre_liquidacoes                  pre
JOIN der_ce_financeiro_imposto.pre_liquidacoes_por_servico_inss pls ON pre.id = pls.id_pre_liquidacao
JOIN der_ce_financeiro_imposto.base_calculo_inss_por_servico    bcs ON bcs.id = pls.id_servico_inss
WHERE pre.id_tipo_origem = 2; -- 2-Tipo Origem = Medição Conserva

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_municipios_servicos
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoMunicipioServico.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_municipios_servicos AS
SELECT pms.id,
       pre.id_despesa_origem       AS id_medicao,
       pms.id_municipio_iss        AS municipio_codigo,
       cid.nome || ' - ' || cid.uf AS municipio_nome,
       pms.id_servico_inss         AS servico_codigo,
       bcs.descricao               AS servico_descricao,
       pms.perc_part_mun_ser,
       pms.valor_medido_pi,
       pms.valor_adicional,
       pms.valor_despesa,
       pms.observacao
FROM der_ce_financeiro_imposto.pre_liquidacoes                       pre
JOIN der_ce_financeiro_imposto.pre_liquidacoes_por_municipio_servico pms ON pre.id = pms.id_pre_liquidacao
JOIN der_ce_coorporativo.cidades                                     cid ON cid.id = pms.id_municipio_iss
JOIN der_ce_financeiro_imposto.base_calculo_inss_por_servico         bcs ON bcs.id = pms.id_servico_inss
WHERE pre.id_tipo_origem = 2; -- 2-Tipo Origem = Medição Conserva

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_docs_digitais
-- CLASSE..: controle_conservacao.medicoes.VoFichaMedicaoDocsDigitais.java 
-- Objetivo: Compor a ficha de Medição dos Contratos de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_docs_digitais AS
SELECT doc.id,
       med.id               AS id_medicao,
       tdo.descricao        AS documento,
       doc.versao_arquivo   AS versao,    
       to_char(doc.data_hora_upload,'dd/mm/yyyy HH24:MI'::text) AS data_upload,
       doc.path_arquivo     AS caminho_arquivo,
       doc.nome_arquivo,
       tar.media_type,
       doc.observacao
FROM controle_conservacao.medicoes          med
JOIN documento_digital.documentos_digitais  doc ON med.id::text = doc.id_entidade
JOIN documento_digital.tipo_arquivo         tar ON tar.id = doc.id_tipo_arquivo
JOIN documento_digital.tipo_documento       tdo ON tdo.id = doc.id_tipo_documento
WHERE tdo.id_tipo_entidade = 122;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_capa_medicao
-- CLASSE..: controle_conservacao.medicoes.VoCapaMedicao.java 
-- Objetivo: Retorna informações do Relatório: Capa de Medição de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_capa_medicao AS
SELECT ctr.nr_contrato_der,
       CASE WHEN ctr.nr_contrato_sic IS NULL THEN '' ELSE ctr.nr_contrato_sic END AS nr_contrato_sic,
       CASE WHEN ctr.nr_contrato_ext IS NULL THEN '' ELSE ctr.nr_contrato_ext END AS nr_contrato_ext,
       CASE WHEN fun.nome_completo   IS NULL THEN '' ELSE fun.nome_completo   END AS gestor,
       ctr.objeto,
       ctd.razao_social AS contratada,
       ctr.data_fim_vigencia,
       ctr.data_fim_execucao,
       dis.nome AS distrito_operacional,
       med.id,
       med.nr_medicao,
       med.nr_recibo,
       moh.data_hora_apresentacao,
       sfs.descricao AS status_fisico,
       'Referente ao Periodo: ' || 
       substr(pmo.ano_mes,5,2) || '-' || substr(pmo.ano_mes,1,4) || ' de ' || 
       to_char(pmo.data_inicio_periodo,'dd/mm/yyyy') || ' até '  || 
       to_char(pmo.data_fim_periodo   ,'dd/mm/yyyy')     AS periodo_referencia,
       to_char(med.data_inicio, 'dd/mm/yyyy') || ' - ' || 
       to_char(med.data_fim,    'dd/mm/yyyy')            AS periodo_medido,
       CASE WHEN med.data_hora_protocolo IS NULL
            THEN '' ELSE to_char(med.data_hora_protocolo, 'dd/mm/yyyy HH24:MI')
       END  AS data_hora_protocolo,
       COALESCE(med.nr_protocolo,'') AS nr_protocolo,
       sfn.descricao                 AS status_financeiro,
       COALESCE(med.valor_medido           ,0) AS valor_medido,
       COALESCE(med.valor_ref_glosa        ,0) AS valor_ref_glosa,
       COALESCE(med.valor_reajuste         ,0) AS valor_reajuste,
       COALESCE(med.valor_ajuste_contratual,0) AS valor_ajuste_contratual,
       COALESCE(med.valor_processo         ,0) AS valor_processo
FROM controle_conservacao.medicoes                  med
JOIN controle_conservacao.status_medicao_fisico     sfs ON sfs.id = med.id_status_fisico
JOIN controle_conservacao.status_medicao_financeiro sfn ON sfn.id = med.id_status_financeiro
JOIN der_ce_contrato.contratos                      ctr ON ctr.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada              ctd ON ctd.id = ctr.id_contratada
JOIN der_ce_coorporativo.distritos_operacionais     dis ON dis.id = ctr.id_distrito
JOIN der_ce_medicao.periodos_medicoes_obras         pmo ON pmo.id = med.id_periodo
JOIN der_ce_coorporativo.vw_funcionario             fun ON fun.id = ctr.id_gestor
LEFT JOIN (SELECT medicoes_obras_historicos.id_medicao,
                  max(medicoes_obras_historicos.data_hora) AS
                  data_hora_apresentacao
             FROM der_ce_medicao.medicoes_obras_historicos
            WHERE medicoes_obras_historicos.id_tipo_historico IN (2,3) -- 2-Valor 3-Zero
         GROUP BY medicoes_obras_historicos.id_medicao
          ) moh ON moh.id_medicao = med.id
WHERE med.id_status_fisico > 1;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_justificativa_medicao_zero
-- CLASSE..: controle_conservacao.medicoes.VoJustificativaMedicaoZero.java 
-- Objetivo: Retorna informações do Relatório: Justificativa Medição ZERO de Conserva
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_justificativa_medicao_zero AS
SELECT med.id,
       med.nr_medicao,
       to_char(med.data_inicio,'dd/mm/yyyy') AS data_inicio,
       to_char(med.data_fim   ,'dd/mm/yyyy') AS data_fim,
       med.obs_responsavel                   AS justificativa,
       per.ano_mes,
       SUBSTRING(per.ano_mes,5,2) || '-' || 
       SUBSTRING(per.ano_mes,1,4)            AS mes_ano,
       con.nr_contrato_der AS contrato_der,
       cta.razao_social    AS contratada,
       cta.cnpj            AS contratada_cnpj,
       dop.nome            AS distrito
FROM controle_conservacao.medicoes          med
JOIN der_ce_medicao.periodos_medicoes_obras per ON per.id = med.id_periodo
JOIN der_ce_contrato.contratos              con ON con.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada      cta ON cta.id = con.id_contratada
LEFT JOIN der_ce_coorporativo.distritos_operacionais dop ON dop.id = con.id_distrito
  WHERE med.valor_medido = 0;
 
 -- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_certificado_entrega
-- CLASSE..: controle_conservacao.VoCertificadoEntrega.java
-- Objetivo: Retorna informações do Relatório: Certificado de entrega da medição
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_certificado_entrega AS
SELECT
  med.id,
  ctd.nome_fantasia,
  ctd.razao_social,
  med.nr_medicao,
  'Certificamos, que a '
  || ctd.nome_fantasia   || ', executou para esta Superintendência os Serviços de '
  || con.objeto          || ', no período de '
  || to_char(med.data_inicio,'dd/mm/yyyy')  || ' a '
  || to_char(med.data_fim   ,'dd/mm/yyyy')  || ', constantes no relatório anexo, relativo à '
  || med.nr_medicao      || 'a. Medição, no valor de R$ '
  || to_char(med.valor_medido,  'FM999G999G990D00') || ' (PI) '
  || ' e que os mesmos atendem aos projetos de especificações pertinentes ao contrato No.'
  || con.nr_contrato_der || '.' AS texto_certificado_entrega,
  'Gerente do ' || dop.nome     AS label_gerente,
  fun.nome_completo             AS gerente
FROM controle_conservacao.medicoes     med
JOIN der_ce_contrato.contratos         con ON con.id = med.id_contrato
JOIN der_ce_coorporativo.vw_contratada ctd ON ctd.id = con.id_contratada
JOIN der_ce_coorporativo.vw_funcionario         fun ON fun.id = con.id_gestor
JOIN der_ce_coorporativo.distritos_operacionais dop ON dop.id = con.id_distrito
WHERE med.id_status_fisico NOT IN (1); -- Quando não 1-Aberta

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_medicao_conserva_fiscais
-- CLASSE..: controle_conservacao.VoMedicaoFiscais.java
-- Objetivo: Retorna lista de fiscais da Comissão Fiscalização
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_medicao_conserva_fiscais AS
SELECT mof.id,
         mof.id_contrato,
         mof.id_medicao,
         mof.id_tipo_fiscal,
         tfi.descricao AS tipo,
         fun.matricula,
         fun.nome_referencia AS nome,
         fun.codigo_conselho AS crea,
         fun.nome_completo,
         CASE WHEN fun.codigo_conselho IS NULL 
              THEN fun.matricula || ' - ' || fun.nome_completo
              ELSE fun.matricula || ' - ' || fun.nome_completo || ' (Crea: ' || fun.codigo_conselho || ')'
         END AS assinatura,
         fun.email
FROM controle_conservacao.medicoes_fiscais mof
JOIN der_ce_obra.tipo_fiscal               tfi ON tfi.id = mof.id_tipo_fiscal
JOIN der_ce_coorporativo.vw_funcionario    fun ON fun.id = mof.id_fiscal;

-- =============================================================================
--
-- FIM: C R I A Ç Â O   d a s   V I E W S 
--
-- =============================================================================

-- =============================================================================
-- VIEW....: controle_conservacao.vw_ficha_contrato
-- CLASSE..: der.ce.controle_conservacao.VoFichaContrato  
-- OBJETIVO: Compor a ficha do Contrato
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato AS
SELECT 
  ctr.id,
  -- Identificação do Contrato
  tpc.cor_tipo   AS tipo_cor,
  tpc.sigla      AS tipo_sigla,
  tpc.descricao  AS tipo_descricao,
  ctr.nr_mapp,
  ctr.nr_protocolo,
  ctr.nr_licitacao,
  ctr.nr_contrato_der,
  ctr.nr_contrato_ext,
  ctr.nr_contrato_sic,
  ctr.objeto,
  stc.cor_status AS status_cor,
  stc.sigla      AS status_sigla,
  stc.descricao  AS status_descricao,
  ctr.observacao,
  -- Datas Relevantes
  ctr.data_proposta,
  ctr.data_assinatura,
  ctr.data_publicacao,
  ctr.data_encerramento,
  -- Prazo de Vigencia
  CASE  ctr.tipo_data_inicial
    WHEN 1 THEN 'Publicação'
    WHEN 2 THEN 'Assinatura'
    WHEN 3 THEN 'Ordem Serviço'
    ELSE        'Não Informado'
  END            AS data_inicio,
  ctr.prazo_inicial,
  ctr.dias_adicionado,
  ctr.dias_suspenso,
  ctr.data_fim_vigencia,
  -- Prazo de Execucao
  ctr.nr_ordem_servico,
  ctr.data_ordem_servico,
  ctr.data_fim_execucao,
  -- ------------------------------------------------------------------------------
  -- Envolvidos
  -- ------------------------------------------------------------------------------
  -- Gestor do Contrato
  ges.matricula     AS gestor_matricula,
  ges.nome_completo AS gestor_nome,
  ges.sigla_setor   AS gestor_setor,
  -- Contratada
  ctd.cnpj          AS contratada_cnpj,
  ctd.razao_social  AS contratada_razao_social,
  ctd.nome_fantasia AS contratada_nome_fantasia,
  -- Contratante
  ctt.cnpj          AS contratante_cnpj,
  ctt.razao_social  AS contratante_razao_social,
  ctt.nome_fantasia AS contratante_nome_fantasia,
  dop.nome          AS distrito_operacional,
  -- --------------------------------------------------------------------------- 
  -- Indicadores
  CASE WHEN ctr.exige_garantia THEN 'Sim' ELSE 'Não' END exige_garantia,
  tci.sigla              AS calcula_imposto_sigla,
  tci.descricao          AS calcula_imposto_descricao,
  tci.especificacao      AS calcula_imposto_especificacao,
  irr.descricao          AS irrf_descricao,
  irr.perc_al_irrf       AS irrf_aliquota,
  -- --------------------------------------------------------------------------- 
  -- Valores Globais do Contrato
  vpc.valor_original,       -- (A)
  vpc.total_aditivo,        -- (B)
  vpc.valor_pi,             -- (C)=(A+B)
  vpc.total_reajuste,       -- (D)
  vpc.valor_atual,          -- (E)=(C+D)
  -- ---------------------------------------------------------------------------  
  -- Valores de Execução do Contrato
  vpc.total_medido_pi,      -- (F) - Somatório dos valores medido a PI nas Medições  
  vpc.total_reajuste_med,   -- (G) - Somatório dos reajuste das Medições
  vpc.total_ajuste,         -- (H) - Somatório dos Ajustes Contratuais das Medições
  vpc.total_ref_glosa,      -- (I) - Somatório das Glosas das Medições  
  vpc.total_despesa_adic,   -- (X) - Somatório dos Valores Adicionais do contrato
  vpc.total_processo,       -- (J) = (F+G+H+I+X) - valor total Protocolado
  -- ---------------------------------------------------------------------------
  -- Valores financeiros do contrato
  vpc.percentual_executado_pi AS percentual_executado, 
                            -- (K) - Percentual Executado do valor PI do contrato
  vpc.total_empenhado,      -- (L) - Somatórios dos valores Empenhado 
  vpc.total_pago,           -- (M) - Somatórios dos valores Pagos  
  vpc.saldo_a_pagar,        -- (N)=(J-M) - Saldo a Pagar do que já foi protocolado
  vpc.saldo_a_medir,        -- (O)=(C-F-U) - Saldo a Medir do valor PI do Contrato
  vpc.saldo_a_investir,     -- (P)=(N+O) - Saldo a Investir do valor atual do Contrato
  vpc.saldo_bloqueado       -- (U) -> Somatório dos saldos a medir (Periodo Vigência)
FROM       der_ce_contrato.contratos                  ctr
INNER JOIN der_ce_contrato.status_contrato            stc ON stc.id = ctr.id_status
INNER JOIN der_ce_contrato.tipo_contrato              tpc ON tpc.id = ctr.tipo
LEFT JOIN der_ce_contrato.vw_valores_por_contrato    vpc ON vpc.id = ctr.id
LEFT  JOIN der_ce_contrato.tipo_calculo_imposto       tci ON tci.id = ctr.id_calcula_imposto
LEFT  JOIN der_ce_financeiro_imposto.aliquota_irrf    irr ON irr.id = ctr.id_aliquota_irrf
LEFT  JOIN der_ce_coorporativo.distritos_operacionais dop ON dop.id = ctr.id_distrito
INNER JOIN der_ce_coorporativo.vw_contratada          ctd ON ctd.id = ctr.id_contratada
INNER JOIN der_ce_coorporativo.vw_contratante         ctt ON ctt.id = ctr.id_contratante
LEFT  JOIN der_ce_coorporativo.vw_funcionario         ges ON ges.id = ctr.id_gestor;


-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_contrato_periodos_vigencia
-- CLASSE..: controle_conservacao.VoFichaContratoPeriodosVigencia.java
-- Objetivo: Usar na composição da ficha do Contrato
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_periodos_vigencia AS 
SELECT 
  cpv.id,
  cpv.id_contrato,
  cpv.nr_periodo,
  spv.id        AS status_id,
  spv.cor       AS status_cor,
  spv.sigla     AS status_sigla,
  spv.descricao AS status_descricao,
  cpv.vig_inicio_periodo,
  cpv.vig_prazo_periodo,
  cpv.vig_termino_periodo,
  cpv.val_inicial_periodo,
  cpv.val_aditivado_periodo,
  cpv.val_pi_periodo,
  cpv.vig_prazo_renovado,
  cpv.vig_termino_renovado,
  cpv.val_renovacao,
  cpv.med_qtd_periodo,
  cpv.med_valor_medido_periodo,
  cpv.med_saldo_a_medir_periodo,
  CASE WHEN cpv.med_saldo_bloqueado THEN 'Sim' ELSE 'Não' END med_saldo_bloqueado,
  cpv.observacao,  
  alt.nr_protocolo
FROM der_ce_contrato.contratos_periodos_vigencia cpv
JOIN der_ce_contrato.status_periodo_vigencia     spv ON spv.id = cpv.id_status_periodo
LEFT JOIN der_ce_contrato_alteracoes.alteracoes_contratuais alt ON alt.id = cpv.id_alteracao_contratual
ORDER BY cpv.id_contrato, cpv.nr_periodo;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_contrato_municipios_iss
-- CLASSE..: controle_conservacao.VoFichaContratoMunicipiosIss.java
-- Objetivo: Usar na composição da ficha do Contrato
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_municipios_iss AS 
SELECT
  cmu.id,
  cmu.id_contrato,
  cmu.id_municipio_iss AS municipio_codigo,
  mun.nome             AS municipio_nome,
  mun.uf               AS municipio_uf,
  alq.perc_al_iss      AS municipio_perc_al_iss,
  alq.perc_bc_iss      AS municipio_perc_bc_iss,
  cmu.observacao       AS municipio_observacao
FROM        der_ce_contrato.contratos_municipios_iss             cmu
 INNER JOIN der_ce_financeiro_imposto.aliquota_iss_por_municipio alq ON alq.id_municipio_iss = cmu.id_municipio_iss
 INNER JOIN der_ce_coorporativo.cidades                          mun ON mun.id = alq.id_municipio_iss
ORDER BY cmu.id_contrato, mun.nome;

-- =============================================================================
-- VIEW....: controle_conservacao.vw_ficha_contrato_medicoes
-- CLASSE..: controle_conservacao.VoFichaContratoMedicoes
-- OBJETIVO: Compor a ficha do Contrato
-- =============================================================================
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_medicoes AS
SELECT 
    med.id_contrato,
    med.id,
    med.nr_medicao,
    med.nr_protocolo,
    med.data_hora_protocolo,
    SUBSTRING(pmo.ano_mes,5,2) || '-' || 
    SUBSTRING(pmo.ano_mes,1,4)      AS Periodo,
    med.data_inicio,
    med.data_fim,
    -- Status Fisico
    sfs.cor                         AS status_fisico_cor,
    sfs.sigla                       AS status_fisico_sigla, 
    sfs.descricao                   AS status_fisico_descricao,     
    -- Status Financeiro
    sfn.cor                         AS status_financeiro_cor,
    sfn.sigla                       AS status_financeiro_sigla, 
    sfn.descricao                   AS status_financeiro_descricao, 
    -- Valores
    med.valor_medido                AS valor_medido_pi,
    med.valor_ref_glosa,
    med.valor_reajuste,
    med.valor_ajuste_contratual, 
    COALESCE(med.valor_processo ,0)::NUMERIC(16,2) AS valor_processo,
    COALESCE(des.total_empenhado,0)::NUMERIC(16,2) AS valor_empenhado,
    COALESCE(des.total_pago     ,0)::NUMERIC(16,2) AS valor_pago,
   (COALESCE(med.valor_processo ,0) -
    COALESCE(des.total_pago     ,0))::NUMERIC(16,2) AS valor_a_pagar
FROM controle_conservacao.medicoes                  med
JOIN controle_conservacao.status_medicao_fisico     sfs ON sfs.id = med.id_status_fisico
JOIN controle_conservacao.status_medicao_financeiro sfn ON sfn.id = med.id_status_financeiro
JOIN der_ce_medicao.periodos_medicoes_obras         pmo ON pmo.id = med.id_periodo
LEFT  JOIN der_ce_financeiro_despesa.despesas       des ON des.id = med.id_despesa
ORDER BY med.id_contrato, med.nr_medicao;

-- -----------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_contrato_despesas_contrato
-- CLASSE..: controle_conservacao.VoFichaContratoDespesasContrato.java
-- Objetivo: Usar na composição da ficha do Contrato
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_despesas_contrato AS 
SELECT
  dct.id,
  dct.id_contrato,
  dct.nr_despesa,
  dct.nr_protocolo,
  dct.data_protocolo,
  dct.ano_mes_referencia,
  dct.objeto,
  dct.valor_despesa,
  tdc.sigla     AS tipo_sigla,
  tdc.descricao AS tipo_descricao,
  sdc.cor       AS status_cor,
  sdc.sigla     AS status_sigla,
  sdc.nome      AS status_descricao,
  dct.observacao
FROM       der_ce_contrato_despesas.despesas_contrato       dct
INNER JOIN der_ce_contrato_despesas.tipo_despesa_contrato   tdc ON tdc.id = dct.id_tipo
INNER JOIN der_ce_contrato_despesas.status_despesa_contrato sdc ON sdc.id = dct.id_status
ORDER BY dct.id_contrato, dct.nr_despesa;

--------------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_contrato_historicos
-- CLASSE..: controle_conservacao.VoFichaContratoHistoricos.java
-- Objetivo: Usar na composição da ficha do Contrato
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_historicos AS
SELECT chi.id_contrato,
       chi.id,
       chi.matricula  AS usuario,
       chi.data_hora,
       thc.descricao  AS tipo,
       chi.observacao AS complemento
FROM   der_ce_contrato.contratos_historicos    chi INNER JOIN 
       der_ce_contrato.tipo_historico_contrato thc ON thc.id = chi.id_tipo_historico
ORDER BY chi.id_contrato, chi.data_hora;
      
--------------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_contrato_comissao
-- CLASSE..: controle_conservacao.VoFichaContratoComissao.java
-- Objetivo: Usar na composição da ficha do Contrato
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_contrato_comissao AS
SELECT ctf.id_contrato,
       ctf.id,
       ctf.id_tipo_fiscal  AS id_tipo,
       tpf.descricao       AS tipo,
       fun.matricula,
       fun.nome_completo   AS nome,
       fun.codigo_conselho AS crea
FROM controle_conservacao.contratos_fiscais ctf
JOIN der_ce_obra.tipo_fiscal                tpf ON tpf.id = ctf.id_tipo_fiscal 
JOIN der_ce_coorporativo.vw_funcionario     fun ON fun.id = ctf.id_fiscal
ORDER BY ctf.id_contrato, ctf.id_tipo_fiscal;
      
--------------------------------------------------------------------------------
-- VIEW....: controle_conservacao.vw_ficha_medicao_comissao
-- CLASSE..: controle_conservacao.VoFichaMedicaoComissao.java
-- Objetivo: Usar na composição da ficha do Contrato
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW controle_conservacao.vw_ficha_medicao_comissao AS
SELECT mdf.id_medicao,
       mdf.id,
       mdf.id_tipo_fiscal  AS id_tipo,
       tpf.descricao       AS tipo,
       fun.matricula,
       fun.nome_completo   AS nome,
       fun.codigo_conselho AS crea
FROM controle_conservacao.medicoes_fiscais mdf
JOIN der_ce_obra.tipo_fiscal                tpf ON tpf.id = mdf.id_tipo_fiscal  
JOIN der_ce_coorporativo.vw_funcionario     fun ON fun.id = mdf.id_fiscal;