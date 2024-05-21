-- =============================================================================
--
-- INICIO: I N T E G R A Ç Ã O   D O C U M E N T O S   D I G I T A I S 
--
-- =============================================================================
-- --------------------------------------------------------------------------------
-- Inserir Novo Tipo de Origem para Documentos Digitais gerados pelo Módulo de CONSERVA
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_origem_arquivo (id, cor, sigla, descricao, especificacao)
VALUES (7, '#000000', 'SSC', 'SIGSOP-Conserva','Documentos Gerados pelo Sistemas de Controle de Conservação de Rodovias');


-- --------------------------------------------------------------------------------
-- Relação de Tipos de Entidades para Gestão de Documentos digitais de conserva 
-- --------------------------------------------------------------------------------
-- Exclui referencia anterior dos codigos de Supervisão
DELETE FROM documento_digital.ponto_controle_x_tipo_doc 
      WHERE id_ponto_controle IN (SELECT qry.id as id_ponto_controle
                                    FROM documento_digital.ponto_controle qry 
                                   WHERE qry.id_tipo_entidade = 122);
                                   
DELETE FROM documento_digital.tipo_documento_x_tipo_assinador 
      WHERE id_tipo_documento IN (SELECT qry.id as id_tipo_documento
                                    FROM documento_digital.tipo_documento qry 
                                   WHERE qry.id_tipo_entidade = 122);
                                       
DELETE FROM documento_digital.ponto_controle WHERE id_tipo_entidade = 122;
DELETE FROM documento_digital.tipo_documento WHERE id_tipo_entidade = 122;
DELETE FROM documento_digital.tipo_assinador WHERE id in (113,114);
DELETE FROM documento_digital.tipo_entidade  WHERE id >=120 AND id <=133;

-- Inclui no lgar de supervisão os códigos de conserva
INSERT INTO documento_digital.tipo_entidade (id, id_tipo_entidade_pai, pasta, descricao, observacao) VALUES
--(120 ,100 ,'CTRCON' ,'Contrato de Conservação Rodoviaria'    ,'Documentos Relativos a operacionalização das Conservação de Rodovia'),
--(121 ,120 ,'CONPLA' ,'Planilha de Conservação das Rodovias'  ,'Documentos Relativos as planilhas de Conserva Rodoviaria'),
(122 ,100 ,'CONMED' ,'Medição da Conserva Rodoviaris'        ,'Documentos Relativos ao processo administrativo das medições de Conserva Rodoviaria'),
(123 ,122 ,'CONFIN' ,'Financeiro Medicao Conserva Rodoviaria','Documentos Relativos ao processo financeiro das medições de Conserva Rodoviaria');

-- Cadastra novamente as referencias a supervisão com novos códigos
INSERT INTO documento_digital.tipo_entidade (id, id_tipo_entidade_pai, pasta, descricao, observacao) VALUES
(130 ,100 ,'CTRSUP' ,'Supervisao de Obra'                    ,'Documentos Relativos a operacionalização das supervisões de obras de Rodovia'),
(131 ,130 ,'SUPPLA' ,'Planilha de Supervisão de Obras'       ,'Documentos Relativos as planilhas de supervisão de obras de Rodovia'),
(132 ,130 ,'SUPMED' ,'Medição da Supervisão de Obras'        ,'Documentos Relativos ao processo administrativo das medições de supervisão de obras de Rodovia'),
(133 ,130 ,'SUPFIN' ,'Financeiro das Supervisões de Obras'   ,'Documentos Relativos ao processo Financeiro das medições de supervisão de obras de Rodovia');

-- --------------------------------------------------------------------------------
-- Reçlação de Tipos de Assinadores referente a Gestão de Documentos digitais de conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_assinador(id,tipo,id_assinador,cpf_assinador,descricao,label_etiqueta,especificacao) VALUES 
(113, 2, NULL, NULL, 'FISCAL_CONSERVA_RODOVIARIA', 'COMISSÃO', 'Comissao responsável pela medição de obra de edificações'),
(114, 2, NULL, NULL, 'COMISSAO_CONSERVA_RODOVIAS', 'COMISSÃO', 'Comissao responsável pela medição de manutenção de edificações');

-- --------------------------------------------------------------------------------
-- Relação de Pontos de Controle referente a Gestão de Documentos digitais de conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.ponto_controle (id_tipo_entidade, id, requer_liberacao, id_tipo_ocorrencia_pce, id_validacao_adicional, sigla, descricao, especificacao) VALUES 
(122, 12221, FALSE, 1, 0, 'MCOAAZ', 'Med. Conserva Rod. (Antes de Apresentar Medição ZERO)',      'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Apresentar Medição ZERO)'),
(122, 12225, TRUE , 1, 0, 'MCOAPZ', 'Med. Conserva Rod. (Antes de Protocolar Medição ZERO)',      'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Protocolar Medição ZERO)'),
(122, 12231, TRUE , 1, 0, 'MCOAPV', 'Med. Conserva Rod. (Antes de Apresentar Medição com Valor)', 'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Apresentar Medição com Valor)'),
(122, 12235, TRUE , 1, 0, 'MCOAPR', 'Med. Conserva Rod. (Antes de Protocolar Medição)',           'Validar Documentos Digitais Relativos a Medições de Conserva Rodoviaria (Antes de Protocolar Medição)'),
(123, 12345, TRUE , 2, 2, 'MCOAFE', 'Med. Conserva Rod. (Antes de Finalizar Empenho(s))',         'Validar Documentos Digitais Relativos ao Aspecto Financeiro da Medições de Conserva Rodoviaria (Antes de Finalizar Empenho(s))'),
(123, 12347, TRUE , 1, 3, 'MCOAFP', 'Med. Conserva Rod. (Antes de Finalizar Pagamento(s))',       'Validar Documentos Digitais Relativos ao Aspecto Financeiro da Medições de Conserva Rodoviaria (Antes de Finalizar Pagamento(s))');

-- --------------------------------------------------------------------------------
-- Relação de Tipos de Documentos Referente a Medição de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_documento (id_tipo_entidade, id, id_tipo_versao, id_tipo_origem, requer_assinatura, unico_por_entidade, descricao, nome_arquivo, especificacao) VALUES 
(122, 12201, 0, 7, 'False','True', 'Capa de Medição',                'CapaMedicaoConserva',          'Relatório com informações sumarizadas da medição que serve como capa do processo da medição'),
(122, 12202, 0, 7, 'True', 'True', 'Justificatica de Medição ZERO',  'JustificativaMedicaoZero',     'Relatório que exibe uma justificativa informada pela empresa sobre o motivo da medição ser ZERO.'),
(122, 12203, 0, 7, 'False','True', 'Ficha do Contrato',              'FichaContratoConserva',        'Relatório com informações da Ficha doc ontrato de Conservação'),
(122, 12204, 0, 7, 'True', 'True', 'Certificado Entrega Medição',    'CertificadoEntregaMedicao',    'Relatório que atesta a entrega da medição.'),
(122, 12205, 0, 7, 'True', 'True', 'Ficha da Medição',               'FichaMedicaoConserva',         'Relatório com informações da Ficha doc ontrato de Conservação.'),
(122, 12206, 0, 3, 'True', 'True', 'Relatorio Fotográfico',          'RelatorioFotografico',         'Documento externo incluido via UPLOAD'),
(122, 12207, 0, 3, 'True', 'True', 'Relatorio Segurança do Trabalho','RelatorioSegurancaTrabalho',   'Documento externo incluido via UPLOAD'),
(122, 12208, 0, 3, 'True', 'True', 'Diario de Obra',                 'DiarioObra',                   'Documento externo incluido via UPLOAD'),
(122, 12209, 0, 3, 'True', 'True', 'Boletim de Medição',             'BoletimMedicaoConserva',       'Documento externo incluido via UPLOAD'),
(122, 12210, 0, 3, 'True', 'True', 'Memoria de Cálculo',             'MemoriaCalculoMedicaoConserva','Documento externo incluido via UPLOAD');

-- --------------------------------------------------------------------------------
-- Relação de Assinadores X tipo documento
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.tipo_documento_x_tipo_assinador (id_tipo_documento, id_tipo_assinador) VALUES 		
(12202,5), (12202,114),
(12204,5), 
(12205,5), (12205,114),
(12206,5), 
(12207,5), (12207,114),
(12208,5), (12208,114),
(12209,5), (12209,114);

-- --------------------------------------------------------------------------------
-- Relação de Ponto Controle X Tipo Documento
-- --------------------------------------------------------------------------------
INSERT INTO documento_digital.ponto_controle_x_tipo_doc (id_ponto_controle,id_tipo_documento,id_requer_envio,id_requer_conferencia,id_requer_assinatura,id_requer_carimbo) VALUES 
(12225,12201,12,21,30,40),(12235,12201,12,21,30,40),
(12225,12202,12,21,31,40),
(12225,12203,12,21,30,40),(12235,12203,12,21,30,40),
(12235,12204,12,21,31,40),
(12235,12205,12,21,30,40),
(12231,12206,12,20,30,40),(12235,12206,12,22,31,40),
(12231,12207,12,20,30,40),(12235,12207,12,22,31,40),
(12231,12208,12,20,30,40),(12235,12208,12,22,31,40),
(12231,12209,12,20,30,40),(12235,12209,12,22,31,40),
(12231,12210,12,20,30,40),(12235,12210,12,22,31,40);

-- --------------------------------------------------------------------------------
-- Insere tipo de origem do despacho virtual para contrato de conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.tipo_origem_despacho (id, sigla, nome_tabela, descricao, especificacao) VALUES
(122,'MCROD','controle_conservacao.medicoes', 'Medição de Conserva de Rodovia',	'Despacho com origem no protocolo de Medição de Conserva de Rodovia');

-- --------------------------------------------------------------------------------
-- Relação de Assunto para Tramitação do Despacho Virtual de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.assunto_tramitacao  (id, id_origem, id_setor_origem, descricao, especificacao) VALUES 
(15,122, 332,'Encaminhar Medição','Deve ser informado nas tramitações ref. a medição de obras de rodovias ao sair da GEMED'), 
(16,122,2706,'Encaminhar Medição','Deve ser informado nas tramitações ref. a medição de obras de rodovias ao sair da GEMED'),
(17,122,NULL,'Solicitação de Pagamento de Medição','A definir'),
(18,122,2704,'Autorização de Pagamento de Medição','A definir');

-- --------------------------------------------------------------------------------
-- Relação de Modelo de Tramitação do Despacho Virtual de Conserva
-- --------------------------------------------------------------------------------
INSERT INTO controle_despachos.modelo_tramitacao (id, id_assunto, id_setor_origem, id_dados_modelo, descricao, texto) VALUES 
(12201,16,2706,0,'Encaminhar Medição ZERO'   ,'Informamos que a medição ZERO, foi apresentada pela empresa no sistema SIGSOP-Conserva.'),
(12202,16,2706,0,'Encaminhar Medição PARCIAL','Sr. Diretor, Informamos que a documentação referente a Medição PARCIAL, está em conformidade com os serviços atestados pelo fiscal.'),
(12203,16,2706,0,'Encaminhar Medição FINAL'  ,'Sr. Superintendente, Informamos que a documentação referente a Medição FINAL, está em conformidade com os serviços atestados pelo fiscal.');

-- =============================================================================
--
-- FIM: I N T E G R A Ç Ã O   D O C U M E N T O S   D I G I T A I S 
--
-- =============================================================================

--------------------------------------------------------------------------------
-- VIEW....: documento_digital.vw_lista_id_tipo_entidade_despesa 
-- Objetivo: Utilizado como subquery na view: vw_lista_id_tipo_entidade
--------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW documento_digital.vw_lista_id_tipo_entidade_despesa AS
SELECT CASE WHEN tab.id_tipo_origem = 0 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 1 THEN 113 -- 113-Financeiro de Obra de Rodovias
            WHEN tab.id_tipo_origem = 2 THEN 123 -- 123-Financeiro de Conserva de Rodovias
            WHEN tab.id_tipo_origem = 3 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 4 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 5 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 6 THEN 999 -- 999-A definir
            WHEN tab.id_tipo_origem = 7 THEN 213 -- 213-Financeiro Medições de Obras de Edificações
            WHEN tab.id_tipo_origem = 8 THEN 999 -- 999-A definir
       END              AS id_tipo_entidade,
       tab.id AS id_entidade, 
       CASE WHEN tab.id_tipo_origem = 0        THEN pr1.id_medicao -- 1-Obra de Rodovias
            WHEN tab.id_tipo_origem = 1        THEN pr1.id_medicao -- 1-Obra de Rodovias
            WHEN tab.id_tipo_origem = 2        THEN pr2.id         -- 2-Conserva Rodovias
            WHEN tab.id_tipo_origem IN (2,4,5) THEN prx.id_medicao -- (2-Conserva 4-Projeto 5-Administrativo)
            WHEN tab.id_tipo_origem = 3        THEN pr3.id_medicao -- 3-Supervisão de Obras
            WHEN tab.id_tipo_origem = 7        THEN pr7.id_medicao -- 7-Obras de Edificações
            WHEN tab.id_tipo_origem = 8        THEN pr8.id_medicao -- 8-Manutenção Predial
       END              AS id_entidade_pai,
       tab.nr_protocolo AS codigo_entidade,                
       FALSE            AS pasta_com_codigo
FROM      der_ce_financeiro_despesa.despesas                 tab
LEFT JOIN der_ce_medicao.processos_medicoes_obras            pr1 ON tab.id = pr1.id_despesa AND tab.id_tipo_origem = 1
LEFT JOIN controle_conservacao.medicoes                      pr2 ON tab.id = pr2.id_despesa AND tab.id_tipo_origem = 2
LEFT JOIN der_ce_medicao.processos_medicoes_obras            prx ON tab.id = prx.id_despesa AND tab.id_tipo_origem IN (2,4,5)
LEFT JOIN der_ce_supervisao_new.processo_medicao_supervisao  pr3 ON tab.id = pr3.id_despesa AND tab.id_tipo_origem = 3
LEFT JOIN der_ce_contrato_despesas.despesas_contrato         pr6 ON tab.id = pr6.id_despesa AND tab.id_tipo_origem = 6
LEFT JOIN dae_ce_medicao.processos_medicoes_obras            pr7 ON tab.id = pr7.id_despesa AND tab.id_tipo_origem = 7
LEFT JOIN dae_ce_medicao.processos_medicoes_obras            pr8 ON tab.id = pr8.id_despesa AND tab.id_tipo_origem = 8;


--------------------------------------------------------------------------------
-- VIEW....: documento_digital.vw_lista_id_tipo_entidade 
-- CLASSE..: der.ce.documento_digital.VoListIdTipoEntidade.java
-- Objetivo: Utilizado para Montar o caminho onde do repositório onde os arquivos serão armazenados
--------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW documento_digital.vw_lista_id_tipo_entidade AS
	SELECT row_number() OVER () AS id, 
	       qry.id_tipo_entidade,
	       qry.id_entidade,
	       qry.id_entidade_pai,
	       qry.codigo_entidade,
	       qry.pasta_com_codigo
	FROM (-- =======================================================================
	      -- >>>      ENTIDADES RELACIONADA A CONTRATOS DO SIGSOP-RODOVIAS       <<<
	      -- =======================================================================
	      -- Entidade: 100 - CTRDER - Contrato de Despesa Rodovias
	      SELECT 100                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             NULL                AS id_entidade_pai,
	             tab.nr_contrato_der AS codigo_entidade,
	             TRUE                AS pasta_com_codigo
	      FROM   der_ce_contrato.contratos tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 101 - CTRALT - Alteração Contratual
	      UNION ALL
	      SELECT 101                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_contrato_alteracoes.alteracoes_contratuais tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 102 - CTRDES - Despesa com Contrato (Para Qualquer tipo contrato)
	      UNION ALL
	      SELECT 102                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_contrato_despesas.despesas_contrato tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 103 - CTRMED - Medição Contratos (Para contratos Tipo: (2-Conserva 4-Projeto 5-Administrativo)
	      UNION ALL 
	      SELECT 103                           AS id_tipo_entidade,
	             tab.id                        AS id_entidade,
	             tab.id_contrato               AS id_entidade_pai,
	             to_char(tab.nr_medicao,'000') AS codigo_entidade,
	             TRUE                          AS pasta_com_codigo
	      FROM   der_ce_contrato_medicoes.medicoes_contratos tab	            
	      -- =======================================================================
	      -- >>>           ENTIDADES RELACIONADA A OBRAS RODOVIARIA              <<<
	      -- =======================================================================
	      -- Entidade: 110 - CTROBR - Contrato de Obra
	      UNION ALL 
	      SELECT 110             AS id_tipo_entidade,
	             tab.id          AS id_entidade,
	             tab.id_contrato AS id_entidade_pai,
	             tab.codigo_obra AS codigo_entidade,
	             TRUE            AS pasta_com_codigo
	      FROM   der_ce_obra.obras tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 111 - OBRORC - Orçamento da Obra
	      UNION ALL 
	      SELECT 111             AS id_tipo_entidade,
	             tab.id          AS id_entidade,
	             tab.id_obra     AS id_entidade_pai,
	             obr.codigo_obra AS codigo_entidade,
	             FALSE           AS pasta_com_codigo
	      FROM   der_ce_orcamento.orcamentos tab
	      JOIN   der_ce_obra.obras           obr ON obr.id = tab.id_obra            
	      -- -----------------------------------------------------------------------
	      -- Entidade: 112 - OBRMED - Medição da Obra
	      UNION ALL 
	      SELECT 112                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_obra                    AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   der_ce_medicao.medicoes_obras tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 113 - OBRFIN - Financeiro Medicao Obra
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 113
	      -- =======================================================================
	      -- >>>     ENTIDADES RELACIONADA A CONSERVACAO RODOVIARIA              <<<
	      -- =======================================================================
	      -- Entidade: 122 - CONMED - Medição da Conserva Rodoviaria
	      UNION ALL 
	      SELECT 122                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_contrato                AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   controle_conservacao.medicoes  tab	      
	      -- -----------------------------------------------------------------------
	      -- Entidade: 123 - CONFIN - Financeiro Medicao Conserva Rodoviaria
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 123
	      -- =======================================================================
	      -- >>>     ENTIDADES RELACIONADA A SUPERVISÃO de OBRAS RODOVIARIA      <<<
	      -- =======================================================================
	      -- Entidade: 130 - CTRSUP - Contrato de Supervisao
	      UNION ALL 
	      SELECT 130                 AS id_tipo_entidade,
	             tab.id_contrato     AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             ctr.nr_contrato_der AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.planilha_supervisao_contratada tab
	      JOIN   der_ce_contrato.contratos                            ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 131 - SUPPLA - Planilha de Supervisão
	      UNION ALL 
	      SELECT 131                 AS id_tipo_entidade,
	             tab.id_contrato     AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             ctr.nr_contrato_der AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.planilha_supervisao_contratada tab
	      JOIN   der_ce_contrato.contratos                            ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 132 - SUPMED - Medição da Supervisão de Obra de Rodovias
	      UNION ALL 
	      SELECT 132                            AS id_tipo_entidade,
	             tab.id                         AS id_entidade,
	             tab.id_planilha                AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   der_ce_supervisao_new.medicoes_supervisao tab	      
	      -- -----------------------------------------------------------------------
	      -- Entidade: 133 - SUPFIN - Financeiro das Supervisões de Obras
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE tab.id_tipo_entidade = 133	      
	      -- =======================================================================
	      -- >>>    ENTIDADES RELACIONADA A CONTRATOS DO SIGSOP-EDIFICAÇÕES      <<<
	      -- =======================================================================
	      -- Entidade: 200 - CTRDEE - Contrato de Despesa Edificações
	      UNION ALL
	      SELECT 200                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             NULL                AS id_entidade_pai,
	             tab.nr_contrato_der AS codigo_entidade,
	             TRUE                AS pasta_com_codigo
	      FROM   dae_ce_contrato.contratos tab
	      -- -----------------------------------------------------------------------
	      -- Entidade: 201 - CTRADT - Aditivos de Contrato (Edificações)
	      UNION ALL
	      SELECT 201                 AS id_tipo_entidade,
	             tab.id              AS id_entidade,
	             tab.id_contrato     AS id_entidade_pai,
	             tab.nr_protocolo    AS codigo_entidade,
	             FALSE               AS pasta_com_codigo
	      FROM   dae_ce_contrato.aditivos tab	            
	      -- =======================================================================
	      -- >>>           ENTIDADES RELACIONADA A OBRAS EDIFICAÇÔES             <<<
	      -- =======================================================================
	      -- Entidade: 210 - CTROBE - Contrato Tipo 6: Obra (Edificações)
	      -- Entidade: 220 - CTRMAE - Contrato Tipo 7: Manutenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 220 ELSE 210 END AS id_tipo_entidade, 
	             tab.id          AS id_entidade,
	             tab.id_contrato AS id_entidade_pai,
	             tab.codigo_obra AS codigo_entidade,
	             TRUE            AS pasta_com_codigo
	      FROM   dae_ce_obra.obras             tab
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = tab.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 211 - OBEORC - Orçamento da Obra (Edificações)
	      -- Entidade: 221 - MAEORC - Orçamento da Manutenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 221 ELSE 211 END AS id_tipo_entidade, 
	             tab.id          AS id_entidade,
	             tab.id_obra     AS id_entidade_pai,
	             obr.codigo_obra AS codigo_entidade,
	             FALSE           AS pasta_com_codigo
	      FROM   dae_ce_orcamento.orcamentos   tab
	      JOIN   dae_ce_obra.obras             obr ON obr.id = tab.id_obra
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = obr.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 212 - OBEMED - Medição da Obra (Edificações)
	      -- Entidade: 222 - MAEMED - Medição da Mantenção (Edificações)
	      UNION ALL 
	      SELECT CASE WHEN ctr.tipo = 7 THEN 222 ELSE 212 END AS id_tipo_entidade, 
	             tab.id                         AS id_entidade,
	             tab.id_obra                    AS id_entidade_pai,  
	             to_char(tab.nr_medicao,'000')  AS codigo_entidade,
	             TRUE                           AS pasta_com_codigo
	      FROM   dae_ce_medicao.medicoes_obras tab
	      JOIN   dae_ce_obra.obras             obr ON obr.id = tab.id_obra
	      JOIN   dae_ce_contrato.contratos     ctr ON ctr.id = obr.id_contrato
	      -- -----------------------------------------------------------------------
	      -- Entidade: 213 - OBEFIN - Financeiro Medicao Obra (Edificações)
	      -- Entidade: 223 - MAEFIN - Financeiro Manutenção Predial (Edificações)
	      UNION ALL 
	      SELECT tab.id_tipo_entidade,
	             tab.id_entidade,
	             tab.id_entidade_pai,
	             tab.codigo_entidade,                
	             tab.pasta_com_codigo
	      FROM   documento_digital.vw_lista_id_tipo_entidade_despesa tab
	      WHERE  tab.id_tipo_entidade IN (223,213)
	      -- -----------------------------------------------------------------------
	      -- Entidade: 150 - PREADR - Medição da Supervisão de Obra de Rodovias
          UNION ALL
          SELECT 150    AS id_tipo_entidade,
                 mad.id AS id_entidade,
                 ctr.id AS id_entidade_pai,
                 'ID' || RIGHT('00000' || mad.id, 6) AS codigo_entidade,
                 TRUE   AS pasta_com_codigo
            FROM gestao_contratos.manifestacao_aditivo mad
            JOIN gestao_contratos.contrato_situacao    cst ON cst.id = mad.id_contrato_situacao
            JOIN der_ce_contrato.contratos             ctr ON ctr.id = cst.id_contrato 
                                                          AND cst.origem_contrato = 'RODOVIAS'::text
	      -- -----------------------------------------------------------------------
	      -- Entidade: 250 - PREADE - Medição da Supervisão de Obra de Rodovias
          UNION ALL
          SELECT 250 AS id_tipo_entidade,
                 mad.id AS id_entidade,
                 ctr.id AS id_entidade_pai,
                 'ID' || RIGHT('00000' || mad.id, 6) AS codigo_entidade,
                 TRUE   AS pasta_com_codigo
          FROM gestao_contratos.manifestacao_aditivo mad
          JOIN gestao_contratos.contrato_situacao    cst ON cst.id = mad.id_contrato_situacao
          JOIN dae_ce_contrato.contratos             ctr ON ctr.id = cst.id_contrato 
                                                        AND cst.origem_contrato = 'EDIFICACOES'::text
	      -- -----------------------------------------------------------------------
	      -- Entidade: 550 - EMPCTD - Empresas Contratadas
          UNION ALL
          SELECT 550           AS id_tipo_entidade,
                 ctt.id_pessoa AS id_entidade,
                 NULL::integer AS id_entidade_pai,
                 ctt.cnpj      AS codigo_entidade,
                 TRUE          AS pasta_com_codigo
          FROM der_ce_coorporativo.pessoas_juridicas ctt
	      -- -----------------------------------------------------------------------
	      -- Entidade: 551 - CTDACT - Atestado de Capacidade Técnica
          UNION ALL
          SELECT 551               AS id_tipo_entidade,
                 act.id            AS id_entidade,
                 act.id_contratada AS id_entidade_pai,
                 act.codigo        AS codigo_entidade,
                 FALSE             AS pasta_com_codigo
          FROM der_ce_controle_certidao.act_documentos act
	      -- -----------------------------------------------------------------------
	      -- Entidade: 390 - CONVENIO - Convênio Digital
         UNION ALL
         SELECT 390           AS id_tipo_entidade,
                1             AS id_entidade,
                NULL::integer AS id_entidade_pai,
                ''::character varying AS codigo_entidade,
                FALSE         AS pasta_com_codigo
	      -- -----------------------------------------------------------------------
	      -- Entidade: 395 - PREFEITURA - Prefeitura
         UNION ALL
         SELECT 395          AS id_tipo_entidade,
                pj.id_pessoa AS id_entidade,
                1            AS id_entidade_pai,
                pj.cnpj      AS codigo_entidade,
                true         AS pasta_com_codigo
         FROM der_ce_coorporativo.pessoas_juridicas pj
         WHERE pj.id_tipo_pessoa_juridica = 1
	      -- -----------------------------------------------------------------------
	      -- Entidade: 397 - PREFEITO - Prefeito
         UNION ALL
         SELECT 397          AS id_tipo_entidade,
                p.id         AS id_entidade,
                pj.id_pessoa AS id_entidade_pai,
                p.cpf        AS codigo_entidade,
                true         AS pasta_com_codigo
         FROM convenios.prefeito p
              JOIN der_ce_coorporativo.pessoas_juridicas pj ON pj.id_pessoa = p.id_prefeitura
         WHERE pj.id_tipo_pessoa_juridica = 1
	      -- -----------------------------------------------------------------------
	      -- Entidade: 400 - CVNSOP - Convênio SOP
         UNION ALL
         SELECT 400             AS id_tipo_entidade,
                c.id            AS id_entidade,
                c.id_convenente AS id_entidade_pai,
                'ID'::text || "right"('00000'::text || c.id::text, 6) AS codigo_entidade,
                true            AS pasta_com_codigo
         FROM convenios.convenio c
	      -- -----------------------------------------------------------------------
	      -- Entidade: 410 - CVNSOP - Convênio SOP
         UNION ALL
         SELECT 410     AS id_tipo_entidade,
                clb.id  AS id_entidade,
                cvn.id  AS id_entidade_pai,
                ''::character varying AS codigo_entidade,
                false   AS pasta_com_codigo
         FROM convenios.celebracao clb
         JOIN convenios.convenio   cvn ON cvn.id = clb.id_convenio              
        -- -----------------------------------------------------------------------
	    ) qry;
	    