-- =============================================================================
--
-- INICIO: C R I A Ç Â O   d a s   T R I G G E R S   e   F U N C T I O N S
--
-- =============================================================================
-- -------------------------------------------------------------------------  
-- FUNÇÂO..: fn_per_retorna_id_proximo_periodo_medicao (Id_Referencia)
-- OBJETIVO: Retorna o Id do proximo periodo apartir de um Id de referencia
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION der_ce_medicao_periodo.fn_per_retorna_id_proximo_periodo_medicao (var_id_periodo_refencia integer)
RETURNS INTEGER AS
$body$
DECLARE
  var_id_periodo_retorno INTEGER;
  var_ano_mes_referencia VARCHAR(6);
  var_ano_mes_retorno    VARCHAR(6);
  var_ano_retorno        VARCHAR(4);
  var_mes_retorno        VARCHAR(4);
BEGIN
  -- Recupera Ano Mes do periodo de referencia
  SELECT per.ano_mes INTO  var_ano_mes_referencia
    FROM der_ce_medicao.periodos_medicoes_obras per   
   WHERE per.id = var_id_periodo_refencia;
   
  IF FOUND THEN
     -- Isola Ano e Mes do periodo
     var_ano_retorno =  SUBSTRING(var_ano_mes_referencia,1,4);
     var_mes_retorno =  SUBSTRING(var_ano_mes_referencia,5,2);
     
     -- Recalcula Periodo
     IF var_mes_retorno = '12' THEN                     -- SE Mês for Dezembro
     	var_ano_retorno = var_ano_retorno::INTEGER + 1; --    Próximo Ano
        var_mes_retorno = '01';                         --    Mês Janeiro
     ELSE                                               -- SENAO 
     	var_mes_retorno = var_mes_retorno::INTEGER + 1; --    Próximo Mês
     END IF;     
     var_ano_mes_retorno = var_ano_retorno || var_mes_retorno;
   
     -- Recupera Id do Periodo Calculado
     SELECT per.id INTO  var_id_periodo_retorno
       FROM der_ce_medicao.periodos_medicoes_obras per   
      WHERE per.ano_mes = var_ano_mes_retorno;
  END IF;  
  RETURN var_id_periodo_retorno;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100;

-- -------------------------------------------------------------------------  
-- FUNÇÂO..: fn_per_retorna_id_proximo_periodo_medicao (Ano_Mes_Referencia)
-- OBJETIVO: Retorna o Id do proximo periodo apartir do ANo Mês de Referencia
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION der_ce_medicao_periodo.fn_per_retorna_id_proximo_periodo_medicao (var_periodo_refencia VARCHAR(6))
RETURNS INTEGER AS
$body$
DECLARE
  var_id_periodo_retorno INTEGER;
  var_ano_mes_referencia VARCHAR(6);
  var_ano_mes_retorno    VARCHAR(6);
  var_ano_retorno        VARCHAR(4);
  var_mes_retorno        VARCHAR(4);
BEGIN   
  -- Isola Ano e Mes do periodo
  var_ano_retorno =  SUBSTRING(var_periodo_refencia,1,4);
  var_mes_retorno =  SUBSTRING(var_periodo_refencia,5,2);
    
  -- Recalcula Periodo
  IF var_mes_retorno = '12' THEN                     -- SE Mês for Dezembro
     var_ano_retorno = var_ano_retorno::INTEGER + 1; --    Próximo Ano
     var_mes_retorno = '01';                         --    Mês Janeiro
  ELSE                                               -- SENAO 
     var_mes_retorno = var_mes_retorno::INTEGER + 1; --    Próximo Mês
  END IF;     
  var_ano_mes_retorno = var_ano_retorno || var_mes_retorno;
   
  -- Recupera Id do Periodo Calculado
  SELECT per.id INTO  var_id_periodo_retorno
    FROM der_ce_medicao.periodos_medicoes_obras per   
   WHERE per.ano_mes = var_ano_mes_retorno;
   
  RETURN var_id_periodo_retorno;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Inclui um novo registros de pre_liquidação do tipo: medição de conserva 
-- -----------------------------------------------------------------------------  
CREATE OR REPLACE FUNCTION der_ce_financeiro_imposto.fn_fin_inserir_pre_liquidacao_medicao
   (var_id_tipo_origem integer, var_id_medicao integer)
RETURNS integer AS
$body$
DECLARE
    var_id_pre_liquidacao INTEGER;
BEGIN
    -- ---------------------------------------------------------------------------
    -- Insere registro na tabela pre_liquidacoes
    INSERT INTO der_ce_financeiro_imposto.pre_liquidacoes
         (id_tipo_origem, id_despesa_origem, observacao) 
    VALUES (var_id_tipo_origem, var_id_medicao, 'Incluida automaticamente na abertura da Medição'); 
        
    -- Recupera Id da pré-liquidação inserida no código acima
    SELECT pre.id INTO var_id_pre_liquidacao 
      FROM der_ce_financeiro_imposto.pre_liquidacoes pre
     WHERE pre.id_tipo_origem    = var_id_tipo_origem
       AND pre.id_despesa_origem = var_id_medicao;
      
    -- Insere histórico de pré_liquidação automática
    INSERT INTO der_ce_financeiro_imposto.pre_liquidacoes_historicos
         (id_pre_liquidacao, id_tipo_historico, matricula, observacao) 
    VALUES (var_id_pre_liquidacao, 1, 'SISTEMA', 'Incluida automaticamente na abertura da Medição');
   
    RETURN var_id_pre_liquidacao;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;


-- =============================================================================
-- INICIO: Trigger AFTER da tabela controle_conservacao.contratos_fiscais
-- =============================================================================
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_tga_contratos_fiscais ()
RETURNS SETOF trigger AS
$body$
DECLARE
  var_id_medicao_fiscal INTEGER;
  var_id_tipo_fiscal    INTEGER;
  var_id_fiscal         VARCHAR(8);
  var_acao              VARCHAR(1); -- N-Nenhuma I-Incluir A-Atualizar E-Excluir
  var_id_medicao_atual  INTEGER;
BEGIN
  var_acao = 'N'; -- Ação: Nenhuma Ação 
        
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE'  THEN             
     -- Recupera Medicao Atual da Obra
     SELECT ctr.id_medicao_atual_conserva INTO var_id_medicao_atual
       FROM der_ce_contrato.contratos ctr
      WHERE ctr.id = NEW.id_contrato;
     
     -- Se Existir Medição associada
     IF (NOT var_id_medicao_atual ISNULL) THEN
        -- Verifica se [fiscal] e [tipo] inserido/Alterado na comissão do Contrato já existe na comissão da Medição Atual
        -- -----------------------------------------------------------------------------------------------------------
        SELECT mcf.id_fiscal, mcf.id_tipo_fiscal, mcf.id 
          INTO var_id_fiscal, var_id_tipo_fiscal, var_id_medicao_fiscal
          FROM controle_conservacao.medicoes_fiscais mcf
         WHERE mcf.id_contrato   = NEW.id_contrato
           AND mcf.id_medicao    = var_id_medicao_atual
           AND mcf.id_fiscal     = NEW.id_fiscal
           AND mcf.id_tipo_fiscal= NEW.id_tipo_fiscal;
        
        -- Se [fiscal] e [tipo] inserido no contrato NÃO existe na comissao da Medição Atual   
        IF NOT FOUND THEN 
           -- Verifica se [fiscal] inserido na comissão da obra já existe na comissão da Medição Atual com [tipo] Diferente
           SELECT mcf.id_fiscal, mcf.id_tipo_fiscal, mcf.id 
             INTO var_id_fiscal, var_id_tipo_fiscal, var_id_medicao_fiscal
             FROM controle_conservacao.medicoes_fiscais mcf
            WHERE mcf.id_contrato= NEW.id_contrato
              AND mcf.id_medicao = var_id_medicao_atual
              AND mcf.id_fiscal  = NEW.id_fiscal;
  
           -- Se [fiscal] inserido já existe na comissao da medição com [tipo] Diferente
           IF FOUND THEN
              var_acao    = 'A'; -- Ação: Atualizar Medição fiscais corrigindo o [tipo] e mantendo o [fiscal]
              var_id_tipo_fiscal = NEW.id_tipo_fiscal;           
           
           -- Se [fiscal] inserido NÃO existe na comissao da medição com [tipo] Diferente   
           ELSE
              -- Verifica se [tipo] inserido na comissão da obra já existe na comissão da Medição Atual com [fiscal] Diferente        
              SELECT mcf.id_fiscal, mcf.id_tipo_fiscal, mcf.id 
                INTO var_id_fiscal, var_id_tipo_fiscal, var_id_medicao_fiscal
                FROM controle_conservacao.medicoes_fiscais mcf
               WHERE mcf.id_contrato   = NEW.id_contrato
                 AND mcf.id_medicao    = var_id_medicao_atual
                 AND mcf.id_tipo_fiscal= NEW.id_tipo_fiscal;
              
              -- Se [tipo] inserido já existe na comissao da medição com [fiscal] Diferente
              IF FOUND THEN
                 var_acao      = 'A'; -- Ação: Atualizar Medição fiscais corrigindo o [fiscal] e mantendo o [tipo]
                 var_id_fiscal = NEW.id_fiscal;
              
              -- Se [tipo] inserido NÃO existe na comissao da medição com [fiscal] Diferente
              ELSE
                 var_acao          = 'I'; -- Ação: Inserir Medição Fiscais com dados novos
                 var_id_fiscal     = NEW.id_fiscal;
                 var_id_tipo_fiscal= NEW.id_tipo_fiscal;
              END IF;
           END IF;   
        END IF;          
     
        -- Se for para Inserir
        IF var_acao = 'I' THEN
           INSERT INTO controle_conservacao.medicoes_fiscais
                      (id_contrato,     id_medicao,           id_tipo_fiscal,     id_fiscal) 
           VALUES (NEW.id_contrato, var_id_medicao_atual, var_id_tipo_fiscal, var_id_fiscal);
        
        -- Se for Para Atualizar
        ELSEIF var_acao = 'A' THEN
           UPDATE controle_conservacao.medicoes_fiscais
              SET id_contrato   = NEW.id_contrato,
                  id_medicao    = var_id_medicao_atual,     
                  id_tipo_fiscal= var_id_tipo_fiscal,     
                  id_fiscal     = var_id_fiscal
            WHERE id = var_id_medicao_fiscal;
        END IF;
     END IF;
     RETURN NEW;

  ELSEIF TG_OP = 'DELETE' THEN         
     -- Recupera Medicao Atual da Obra
     SELECT ctr.id_medicao_atual_conserva INTO var_id_medicao_atual
       FROM der_ce_contrato.contratos ctr
      WHERE ctr.id = OLD.id_contrato;
     
     -- Ação: Excluir Medição Fiscais               
      DELETE FROM controle_conservacao.medicoes_fiscais mcf
       WHERE mcf.id_medicao    = var_id_medicao_atual
         AND mcf.id_fiscal     = OLD.id_fiscal
         AND mcf.id_tipo_fiscal= OLD.id_tipo_fiscal
         AND mcf.id_contrato   = OLD.id_contrato;
       
     RETURN OLD;
     
  END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;
-- -----------------------------------------------------------------------------
-- TRIGGER:  tg_con_tga_contratos_fiscais
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_con_tga_contratos_fiscais
AFTER INSERT OR UPDATE OR DELETE ON controle_conservacao.contratos_fiscais
FOR EACH ROW EXECUTE PROCEDURE      controle_conservacao.fn_con_tga_contratos_fiscais();
-- =============================================================================
-- FIM: Trigger AFTER da tabela controle_conservacao.contratos_fiscais
-- =============================================================================

-- =============================================================================
-- INICIO: Trigger BEFORE da tabela controle_conservacao.medicoes
-- =============================================================================
 
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Verifica se protocolo de medição de conserva pode ser incluido 
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_pode_abrir_medicao_conserva (var_id_contrato integer)
RETURNS text AS
$body$
DECLARE
   var_id_periodo_vigencia  INTEGER;
   var_id_ultima_medicao    INTEGER;
   var_nr_ultima_medicao    INTEGER;
   var_id_status_fisico     INTEGER;
   var_qtd_fiscais_contrato INTEGER;
   var_nr_contrato_der      VARCHAR(8);
   var_retorno              text;
BEGIN  
   var_retorno := 'SIM';
   -- --------------------------------------------------------------
   -- Recupera Informações do contrato
   SELECT ctr.nr_contrato_der, ctr.id_medicao_atual_conserva
     INTO var_nr_contrato_der, var_id_ultima_medicao
     FROM der_ce_contrato.contratos ctr 
    WHERE ctr.id = var_id_contrato;
      
   -- Se Contrato NÃO Existir
   IF NOT FOUND THEN
      var_retorno = 'Não Existe contrato cadastroado com Id: [' || var_id_contrato || '].';   
   ELSE   
      -- --------------------------------------------------------------
      -- Verifica se existe Periodo de vigencia Vigente
      SELECT cpv.id INTO var_id_periodo_vigencia
        FROM der_ce_contrato.contratos_periodos_vigencia cpv
       WHERE cpv.id_contrato       = var_id_contrato
         AND cpv.id_status_periodo = 1; -- 1-Status Vigente
         
      -- Se NÃO existir periodo de vigencia ativo               
      IF NOT FOUND THEN
         var_retorno := 'Contrato [' || var_nr_contrato_der || '] é de natureza contínua e não possui nenhum periodo de vigência ativo.';
      ELSE -- Se existir periodo de vigencia ativo 
         -- --------------------------------------------------------------
         -- Verifica se contrato possui Comissão de fiscalização
         SELECT count(ctf.id) INTO var_qtd_fiscais_contrato
           FROM controle_conservacao.contratos_fiscais ctf 
          WHERE ctf.id_contrato = var_id_contrato;
          
         -- Se NÃO Possui fiscais cadastros para o contrato 
         IF COALESCE(var_qtd_fiscais_contrato,0) = 0 THEN
            var_retorno := 'Contrato [' || var_nr_contrato_der || '] Não possui comissão de fiscalização cadastrada.';      
         ELSE              
            -- -------------------------------------------------------------------
            -- Verifica Medição Anterior
            var_id_ultima_medicao = COALESCE(var_id_ultima_medicao,0);       
            
            -- Se Existir medição Anterior registrada
            IF var_id_ultima_medicao > 0 THEN   
               -- Recupera Status Fisico da Medição
               SELECT med.id_status_fisico, med.nr_medicao
                 INTO var_id_status_fisico, var_nr_ultima_medicao
                 FROM controle_conservacao.medicoes med 
                WHERE med.id = var_id_ultima_medicao;
                 
               -- Se Status da medição Anterior Não For FECHADA
               IF var_id_status_fisico <> 7 THEN -- 7-Fechada
                  var_retorno := 'Impossivel Abrir Nova Medição! ' 
                              || 'A última Medição Aberta Nr. [' || var_nr_ultima_medicao 
                              || '] Referente ao Contrato Nr. [' || var_nr_contrato_der
                              || '] Ainda Não Foi Fechada.';  
               END IF;
            END IF;
         END IF;          
      END IF;       
   END IF;
   RETURN var_retorno; 
END
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Verifica se protocolo de medição de conserva pode ser incluido 
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_pode_incluir_protocolo_medicao_conserva(var_nr_protocolo character varying, var_valor_protocolo numeric)
RETURNS TEXT AS
$body$
DECLARE
   var_nr_medicao   INTEGER;
   var_nr_contrato  VARCHAR(8);
   var_objeto       VARCHAR(600);
   var_retorno      text;
BEGIN  
   var_retorno := 'SIM';
   -- Verifica se existe medição com o mesmo protocolo
   SELECT med.nr_medicao, ctr.nr_contrato_der 
     INTO var_nr_medicao, var_nr_contrato
     FROM controle_conservacao.medicoes med
     JOIN der_ce_contrato.contratos     ctr ON ctr.id = med.id_contrato
    WHERE med.nr_protocolo = var_nr_protocolo;
   -- Se já existir medicao registrada com mesmo numero de protocolo
   IF FOUND THEN
      var_retorno := 'Já existe protocolo Nr. [' || var_nr_protocolo || '] cadastrado para a medição Nr. [' || var_nr_medicao || '] do contrato ['|| var_nr_contrato  ||']';
   ELSE
      -- Se for Medição de Valor
      IF var_valor_protocolo > 0 THEN
         -- Verifica se existe despesa financeira com o mesmo protocolo
         SELECT des.objeto INTO var_objeto
           FROM der_ce_financeiro_despesa.despesas des
          WHERE des.nr_protocolo = var_nr_protocolo;
    	 -- Se já existir despesa financeira com o mesmo protocolo
    	 IF FOUND THEN 
            var_retorno := 'Já existe protocolo Nr. [' || var_nr_protocolo || '] cadastrado p/ despesa financeira com objeto: [' || var_objeto || ']';
         ELSE
            -- Verifica se existe despacho com o mesmo protocolo
            SELECT des.objeto INTO var_objeto
              FROM controle_despachos.despachos des
             WHERE des.nr_documento = var_nr_protocolo;
    	    -- Se já existir Despacho com o mesmo protocolo
            IF FOUND THEN
               var_retorno := 'Já existe protocolo Nr. [' || var_nr_protocolo || '] cadastrado p/ despacho com objeto: [' || var_objeto || ']';
            END IF;
         END IF;
      END IF;
   END IF;
  RETURN var_retorno; 
END  
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Inclui um novo despacho de medição de conserva 
-- -----------------------------------------------------------------------------  
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_incluir_despacho_medicao_conserva(var_id_medicao integer, var_nr_protocolo character varying)
RETURNS integer AS
$body$
DECLARE
   var_nr_contrato     VARCHAR(8);  var_interessado     VARCHAR(150);
   var_nr_medicao      INTEGER;     var_valor_medido    NUMERIC(16,2);
   var_periodo_medicao VARCHAR(25); var_objeto          VARCHAR(600);
   var_tipo_origem     VARCHAR(60); var_tipo_medicao    VARCHAR(10);
   var_id_tipo_origem  INTEGER;     var_id_tipo_doc     INTEGER;
   var_id_despacho     INTEGER;     var_id_assunto      INTEGER;
   var_id_modelo       INTEGER;     var_id_setor_origem INTEGER;
   var_id_status       INTEGER;     var_controla_documento_digitais BOOLEAN;
   var_objeto_contrato VARCHAR(255); 
BEGIN     
    -- Recupera informações para o Despacho
    SELECT ctd.razao_social,    ctr.nr_contrato_der,
           med.nr_medicao,      med.valor_medido, 
           to_char(med.data_inicio,'dd/MM/yyyy') || ' a ' ||
           to_char(med.data_fim   ,'dd/MM/yyyy') AS periodo,
           ctr.documentos_digitais,
           ctr.nr_contrato_der,
           ctr.objeto  
      INTO var_interessado,    var_nr_contrato,
           var_nr_medicao,     var_valor_medido,
           var_periodo_medicao,var_controla_documento_digitais,
           var_nr_contrato,    var_objeto_contrato 
      FROM controle_conservacao.medicoes     med 
INNER JOIN der_ce_contrato.contratos         ctr ON ctr.id = med.id_contrato 
INNER JOIN der_ce_coorporativo.vw_contratada ctd ON ctd.id = ctr.id_contratada 
     WHERE med.id = var_id_medicao;
     
    -- Se contrato NÃO controla Documentos Digitais 
    IF (NOT var_controla_documento_digitais) THEN  
        var_id_despacho = NULL;    
    ELSE
        -- Se contrato Controla Documentos Digitais 
        var_tipo_medicao   = 'PARCIAL'; -- CASE WHEN var_medicao_final THEN 'FINAL' ELSE 'PARCIAL' END;
        var_id_setor_origem= 2706; -- [2706-> Setor DIRAD] 
        var_id_tipo_doc    = 1;    -- [1   -> Tipo Documento = Protocolo]
        var_id_tipo_origem = 122;  -- [122 -> Medição de Conserva de Rodovia]
        var_id_assunto     = 16;   -- [16  -> Encaminhar Medição de Conserva]
        var_id_status      = 1;    -- [1   -> Status da Tramitação ABERTA]
        var_objeto         = 'Medição '     || var_tipo_medicao || ' Nº ' || var_nr_medicao       || 
                         ' da Contrato Nº ' || var_nr_contrato  || ' - '  || var_objeto_contrato  || 
                 ', referente ao Período: ' || var_periodo_medicao;
                     
        -- Para Medição com Valor ZERO
        IF (var_valor_medido = 0) THEN
            var_id_modelo = 12201;   --  Modelo [12201] -> Encaminhar Medição ZERO (Conserva)
            var_objeto = var_objeto || ' Valor ZERO';
        ELSE     
            var_id_modelo = 0;        --  Modelo [0] -> Texto Livre
        END IF;
        
        -- Insere despacho automaticamente
        INSERT INTO controle_despachos.despachos
               (id_tipo_documento, nr_documento,   objeto,         
                interessado,      id_tipo_origem, id_origem, observacao)
        VALUES (var_id_tipo_doc, var_nr_protocolo,   var_objeto,
                var_interessado, var_id_tipo_origem, var_id_medicao, 
                'Despacho Integrado com a rotina de Medição de Conserva Rodoviaria.');
        
        -- Pega o Id Gerado na tabela despacho
        SELECT des.id INTO var_id_despacho 
          FROM controle_despachos.despachos des
         WHERE des.nr_documento = var_nr_protocolo;
                         
        -- Recupera Descrição do Tipo de Origem da Despesa
        SELECT tod.descricao INTO var_tipo_origem
          FROM controle_despachos.tipo_origem_despacho tod
         WHERE tod.id = var_id_tipo_origem; 
         
        -- Inclui Historico de inclusão automatica do despacho
        INSERT INTO controle_despachos.despachos_historicos
               (id_despacho,  data_hora,  id_tipo_historico, matricula, observacao)
        VALUES (var_id_despacho, now(), 1,'SISTEMA','Origem [' || var_tipo_origem || ']');
        
        -- Inclui Registro da 1a tramitação do despacho
        INSERT INTO controle_despachos.tramitacoes
                   (id_despacho,    id_status,    id_setor_origem,    id_assunto,    id_modelo)
        VALUES (var_id_despacho,var_id_status,var_id_setor_origem,var_id_assunto,var_id_modelo);                
    END IF;
    -- Retorna Id do despacho PARA tabela de processo medição Obra
    RETURN var_id_despacho;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;

-- -----------------------------------------------------------------------------
-- FUNÇÂO: Inclui um novo registros de pre_liquidação do tipo: medição de conserva 
-- -----------------------------------------------------------------------------  
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_incluir_despesa_medicao_conserva (var_id_medicao integer, var_nr_protocolo varchar(25))
RETURNS integer AS
$body$
DECLARE
    var_id_despesa  INTEGER;    
    var_tipo_origem VARCHAR(60);
BEGIN
    -- Recupera Descrição do Tipo de Origem da Despesa
    SELECT tod.descricao 
      INTO var_tipo_origem
      FROM der_ce_financeiro_despesa.tipo_origem_despesa tod
     WHERE tod.id = 2; -- 2-Medicao de Conserva [id_tipo_contrato <=> id_tipo_origem]
              
    -- Insere despesa automatica de medição de Contratos
    INSERT INTO der_ce_financeiro_despesa.despesas
           (objeto,        nr_protocolo,  data_protocolo, data_vencimento, ano_mes_referencia, 
           valor_despesa, id_pessoa,      id_status,      id_tipo,         id_categoria,   
           id_setor,      id_tipo_origem, id_despesa_origem)
    SELECT SUBSTRING('Ref. a '         || mct.nr_medicao      || 
           'a Medição do Contrato Nº ' || ctr.nr_contrato_der || 
           ' - ' || ctr.objeto ,1,252) || '...', -- Objeto da Despesa
           mct.nr_protocolo,        -- Nr. do Protocolo da Despesa
           mct.data_hora_protocolo, -- Data do Protocolo
           mct.data_hora_protocolo, -- Data de Vencimento da Despesa
           pme.ano_mes,             -- Ano Mes de Referencia da Despesa
           mct.valor_processo,      -- Valor da Despésa
           ctr.id_contratada,       -- Pessoa Juridica Credora da Despesa
           1,                       -- Status       [1   - Aguardando Classificação]
           102,                     -- Tipo Despesa [102 - Medição de Conserva]
           0,                       -- Categoria    [0   - Não Informada]
           null,                    -- Setor        [Nulo-????]
           2,                       -- Tipo Origem [2 - Medição de Conserva]
           mct.id                   -- Id da tabela Medição Contrato Conserva
      FROM controle_conservacao.medicoes          mct
INNER JOIN der_ce_medicao.periodos_medicoes_obras pme ON pme.id = mct.id_periodo
INNER JOIN der_ce_contrato.contratos              ctr ON ctr.id = mct.id_contrato 
     WHERE mct.id = var_id_medicao;
                
    -- Pega o Id Gerado na tabela despesas
    SELECT des.id 
      INTO var_id_despesa 
      FROM der_ce_financeiro_despesa.despesas des
     WHERE des.nr_protocolo = var_nr_protocolo;
                  
    -- Inclui Historico de inclusão automatica da despesa
    INSERT INTO der_ce_financeiro_despesa.despesas_historicos
           (id_despesa,  data_hora,  id_tipo_historico, matricula, observacao)
    VALUES (var_id_despesa, now(), 10,'SISTEMA','Origem [' || var_tipo_origem || ']');
    
    RETURN var_id_despesa;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
   
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "BEFORE" da tabela "controle_conservacao.medicoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_tgb_medicoes()
RETURNS SETOF trigger AS
$body$
DECLARE
    var_nr_contrato_der     text;
    var_nr_recibo           INTEGER;
    var_nr_ultima_medicao   INTEGER;
    var_id_medicao_anterior INTEGER;
    var_id_despesa_origem   INTEGER;
    var_id_periodo_vigencia INTEGER;
    var_valor_despesa       NUMERIC(16,2);
    var_data_hora_inclusao  VARCHAR(20);
    var_msg_pode_incluir_protocolo TEXT;
    var_msg_pode_abrir_medicao     TEXT;
BEGIN
    -- ---------------------------------------------------------------------------
    IF TG_OP = 'INSERT' THEN 
       -- Verifica se pode abrir medição
       var_msg_pode_abrir_medicao    = controle_conservacao.fn_con_pode_abrir_medicao_conserva(NEW.id_contrato);       
       IF var_msg_pode_abrir_medicao = 'SIM' THEN -- Se puder abrir a medição              
          -- Recupera Nr. da Ultima Medição Registrada
          SELECT med.nr_medicao INTO var_nr_ultima_medicao
            FROM der_ce_contrato.contratos     ctr 
            JOIN controle_conservacao.medicoes med ON med.id = ctr.id_medicao_atual_conserva
           WHERE ctr.id = NEW.id_contrato;
            
          var_nr_ultima_medicao = COALESCE(var_nr_ultima_medicao,0); 
          
          -- Recupera id da periodo de vigencia
          SELECT cpv.id INTO var_id_periodo_vigencia
            FROM der_ce_contrato.contratos_periodos_vigencia cpv
           WHERE cpv.id_contrato       = NEW.id_contrato
             AND cpv.id_status_periodo = 1; -- 1-Status Vigente
         
          -- Finaliza Aberture da medição
          NEW.id_pre_liquidacao   = der_ce_financeiro_imposto.fn_fin_inserir_pre_liquidacao_medicao(2, NEW.id); -- Tipo_origem: 2-Medição de Conserva             
          NEW.nr_medicao          = (var_nr_ultima_medicao + 1); -- Gera o nrumero da medição a ser aberta		  
          NEW.id_periodo_vigencia = var_id_periodo_vigencia;     -- Associa a medição ao periodo de vigencia do contrato
       ELSE
          RAISE EXCEPTION '%',var_msg_pode_abrir_medicao;     
       END IF;
       RETURN NEW;
    -- ---------------------------------------------------------------------------
    ELSEIF TG_OP = 'UPDATE' THEN          
        -- Recupera Nr. do Contrato da  Medição
        SELECT ctr.nr_contrato_der INTO var_nr_contrato_der
          FROM der_ce_contrato.contratos ctr 
         WHERE ctr.id = NEW.id_contrato;       
        
        -- ------------------------------------------------------------------------
        -- Se Medição Esta sendo APRESENTADA Gera Nr de Recibo: CCCC/AAAA-MMM.RR
        IF (OLD.id_status_fisico = 1 AND NEW.id_status_fisico IN (2,3)) THEN  -- Status De: 1-ABE para: 2-AVA (Valor) ou 5-AAS (Zero)
            var_nr_recibo := RIGHT(NEW.nr_recibo,2);
            NEW.nr_recibo = LEFT(var_nr_contrato_der,4) || '/' || -- CCCC/
                           RIGHT(var_nr_contrato_der,4) || '-' || -- AAAA-
                    TRIM(to_char(NEW.nr_medicao,'000')) || '.' || -- MMM.
             TRIM(to_char((COALESCE(var_nr_recibo,0) + 1),'00')); -- RR
        END IF;
       
        -- ------------------------------------------------------------------------
        -- Se Medição Esta sendo LIBERADA p/ PROTOCOLAR: Status De: 4-ACO Para: 5-APT 
        IF (OLD.id_status_fisico = 4 AND NEW.id_status_fisico = 5) THEN  
             -- Verifica se conferencia Operacional foi concluida
		     IF NOT NEW.doc_digitais_conferido THEN 
	            RAISE EXCEPTION 'Impossivel Liberar Medição id=[%] p/ Protocolar! Conferencia dos Docs Digitais ainda não Finalizada.',NEW.id;  
		     END IF;
        END IF;
       
        -- ------------------------------------------------------------------------
        -- Se Medição Esta sendo PROTOCOLADA: Status De: 5-APT Para: (Med.VALOR: 6-AAD ou Med. ZERO: 7-FEC) 
        IF (OLD.id_status_fisico = 5 AND NEW.id_status_fisico IN (6,7)) THEN  
	        -- Verifica se protocolo pode ser incluido
	        var_msg_pode_incluir_protocolo   = controle_conservacao.fn_con_pode_incluir_protocolo_medicao_conserva(NEW.nr_protocolo, NEW.valor_processo);
	        IF var_msg_pode_incluir_protocolo = 'SIM' THEN -- Se puder incluir protocolo	           
	           IF NEW.valor_processo = 0 THEN    --    SE for medição de ZERO
	              NEW.id_status_fisico     = 7;  --       Seta Status: 7-FECHADO
	              NEW.id_status_financeiro = 9;  --       Seta Status: 9-Medição ZERO
      	          NEW.id_pre_liquidacao = NULL;  --       Libera Pre-Liquidação p/ ser excluida [tg_con_tga_medicoes]
	           ELSE                              --    SE for medição de VALOR
	              -- Gera 1a Tramitação do despacho de medição de conserva de Rodovias
	              NEW.id_despacho = controle_conservacao.fn_con_incluir_despacho_medicao_conserva(NEW.id, NEW.nr_protocolo);
	           END IF;
	        ELSE
	           RAISE EXCEPTION '%',var_msg_pode_incluir_protocolo;                     
	        END IF;
        END IF;
       
        -- ---------------------------------------------------------------------
        -- Se Medição Está sendo ENCAMINHADA para o Financeiro        
        IF (OLD.id_status_fisico = 6) AND (NEW.id_status_fisico = 7) THEN  -- [6-Aguardando Administrativo <--> 7-Fechada]  
            -- Verifica se Protocolo foi cadastrado na tabela de despesas (Detecta cadastro manual ou Inconsistencia)
            SELECT to_char(des.data_hora_inclusao,'dd/MM/yyyy HH24:MI'), 
                   des.id_despesa_origem, 
                   des.valor_despesa
              INTO var_data_hora_inclusao, 
                   var_id_despesa_origem, 
                   var_valor_despesa
              FROM der_ce_financeiro_despesa.despesas des
             WHERE des.nr_protocolo = NEW.nr_protocolo;
                
            -- --------------------------------------------------------------------------            
            -- Se Protocolo for encontrado na tabela despesas do Módulo Financeiro
            IF FOUND THEN 
                RAISE EXCEPTION 'Já existe um Protocolo Nr. [%] Incluido em [%] com id_despesa_origem=[%] valor_despesa=[%]',
                NEW.nr_protocolo, var_data_hora_inclusao, var_id_despesa_origem, var_valor_despesa;              
            -- ------------------------------------------------------------------
            -- Se Protocolo NÃO for encontrado na tabela despesas do Módulo Financeiro
            ELSE -- Integração com rotina financeira
                NEW.id_status_financeiro = 1; -- 1-Aguardando Classificação
                NEW.id_despesa           = controle_conservacao.fn_con_incluir_despesa_medicao_conserva(
                                           NEW.id,            -- Id da medição (id_despesa_origem)
                                           NEW.nr_protocolo); -- Nr. do protocolo da medição
                
                -- Atualiza dados da Pre_liquidação de IMPOSTOS
                PERFORM der_ce_financeiro_imposto.fn_fin_atualizar_pre_liquidacao (
                        2,                 -- Tipo Origem: 2-Conserva
                        NEW.id_contrato,   -- Id DO Contrato de conserva
                        NEW.id,            -- Id da medição
                        NEW.id_despesa,    -- Id da despesa incluida
                        NEW.valor_medido,  -- Valor Medido PI da medição
                        NEW.valor_processo); -- Valor da medição com adicionais (Glosa, reajuste,..) Caso exista
            END IF;
        END IF;
       
        -- ------------------------------------------------------------------------
        -- Se Medição Ainda NÃO foi ENCAMINHADA Para o Financeiro Atualiza valor do Processo
        IF (NEW.id_status_financeiro = 0) THEN -- [1-Ainda Não Encaminhado]
            NEW.valor_reajuste = NEW.valor_medido * NEW.fator_reajuste;
            NEW.valor_processo = NEW.valor_medido    + NEW.valor_reajuste
                               + NEW.valor_ref_glosa + NEW.valor_ajuste_contratual;
        END IF;
        -- ------------------------------------------------------------------------
        -- Se Medição Já foi ENCAMINHADA Para o Financeiro (Não Permite alterar Valores)
        IF (NEW.id_status_financeiro > 0) THEN -- [1-Ainda Não Encaminhado]
            NEW.valor_processo  =  OLD.valor_processo;
            NEW.valor_medido    =  OLD.valor_medido;
            NEW.fator_reajuste  =  OLD.fator_reajuste;
            NEW.valor_reajuste  =  OLD.valor_reajuste;
            NEW.valor_ref_glosa =  OLD.valor_ref_glosa;
            NEW.valor_ajuste_contratual = OLD.valor_ajuste_contratual;
        END IF;
       
        RETURN NEW;

    -- ---------------------------------------------------------------------------
    ELSEIF TG_OP = 'DELETE' THEN
        -- Verifica se Medição pode ser excluida        
        IF OLD.id_status_fisico > 1 THEN  -- 1-Medicão Aberta
            RAISE EXCEPTION 'Medição Nr. [%] Não Pode ser Excluida! Não Está Mais Aberta.', OLD.nr_medicao;
        ELSEIF (COALESCE(OLD.id_pre_liquidacao,0) <> 0) THEN
            RAISE EXCEPTION 'Medição Nr. [%] Não Pode ser Excluida! Existe Pré Liquidação com Id [%] Associada.', OLD.nr_medicao, OLD.id_pre_liquidacao;
        ELSEIF (COALESCE(OLD.id_despacho,0) <> 0) THEN
            RAISE EXCEPTION 'Medição Nr. [%] Não Pode ser Excluida! Existe Despacho com Id [%] Associado.', OLD.nr_medicao, OLD.id_despacho;
        ELSEIF (COALESCE(OLD.id_despesa,0) <> 0) THEN
            RAISE EXCEPTION 'Medição Nr. [%] Não Pode ser Excluida! Existe Despesa com Id [%] Associada.', OLD.nr_medicao, OLD.id_despesa;
        ELSEIF (COALESCE(OLD.id_despesa_contrato_tipo1,0) <> 0) OR    -- Reajuste Fora do Padrão
               (COALESCE(OLD.id_despesa_contrato_tipo2,0) <> 0) OR    -- Diferença de Reajuste
               (COALESCE(OLD.id_despesa_contrato_tipo3,0) <> 0) THEN  -- Correção Monetaria
            RAISE EXCEPTION 'Medição Nr. [%] Não Pode ser Excluida! Existe Despesa com contrato associada a mesma.', OLD.nr_medicao;
        ELSE
	        -- Exclui registros nas tabelas Filhas da Medição em cascata
            DELETE FROM controle_conservacao.medicoes_historicos  WHERE id_medicao = OLD.id;
            DELETE FROM controle_conservacao.medicoes_ajustes     WHERE id_medicao = OLD.id;
            DELETE FROM controle_conservacao.medicoes_fiscais     WHERE id_medicao = OLD.id;
            DELETE FROM controle_conservacao.medicoes_fora_padrao WHERE id_medicao = OLD.id; 
			
            -- Exclui Pre-liquidação Gerada Automaticamente
            DELETE FROM der_ce_financeiro_imposto.pre_liquidacoes  
             WHERE id_tipo_origem   = 2 -- 2-Conserva
               AND id_despesa_origem= OLD.id;
              
			-- Recupera Id da Medição Anterior após a exclusão
			SELECT med.id INTO var_id_medicao_anterior
			  FROM controle_conservacao.medicoes med
			 WHERE med.nr_medicao = OLD.nr_medicao - 1
			   AND med.id_contrato= OLD.id_contrato;  
			    			    
			-- Atualiza Nova Medição Atual
			UPDATE der_ce_contrato.contratos  
			   SET id_medicao_atual_conserva = var_id_medicao_anterior 
			 WHERE id_medicao_atual_conserva = OLD.id; 
        END IF;     
        RETURN OLD;
    END IF;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;
-- -----------------------------------------------------------------------------
-- TRIGGER: tg_con_tgb_medicoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                       tg_con_tgb_medicoes
BEFORE INSERT OR UPDATE OR DELETE ON controle_conservacao.medicoes
FOR EACH ROW EXECUTE PROCEDURE       controle_conservacao.fn_con_tgb_medicoes();
-- =============================================================================
-- FIM: Trigger BEFORE da tabela controle_conservacao.medicoes
-- =============================================================================

-- =============================================================================
-- INICIO: Alterações nas trigger AFTER controle_conservacao.medicoes
-- =============================================================================
-- -----------------------------------------------------------------------------
-- FUNÇÂO: Ações do tipo "AFTER" da tabela "medicoes"
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_tga_medicoes()
RETURNS trigger AS
$body$
DECLARE
  tot_reajuste_medicao NUMERIC(16,2);
  tot_reajuste_despesa NUMERIC(16,2);
  tot_reajuste         NUMERIC(16,2);
BEGIN
 IF TG_OP = 'INSERT' THEN 
  -- Sincroniza contrato com a ultima medição
  UPDATE der_ce_contrato.contratos 
     SET id_medicao_atual_conserva = NEW.id
   WHERE id = NEW.id_contrato;

  -- Inclui Comissão de fiscalizaçãoda medição apartir da comissão do contrato  
  INSERT INTO controle_conservacao.medicoes_fiscais
         (id_contrato,id_medicao,id_tipo_fiscal,id_fiscal)
  SELECT ctf.id_contrato,
         NEW.id AS id_medicao,
         ctf.id_tipo_fiscal,
         ctf.id_fiscal
    FROM controle_conservacao.contratos_fiscais ctf
   WHERE ctf.id_contrato = NEW.id_contrato;
   
  ELSEIF TG_OP = 'UPDATE' THEN  
  	 -- ---------------------------------------------------------------------
     -- Verifica se valor medido foi alterado
     IF OLD.valor_medido <> NEW.valor_medido THEN        
        IF NEW.id_status_fisico IN (1,2) THEN -- Se Status = (1-Aberta ou 2-Aguardando Validação)
           -- Sincronizar valor da medição com a A Pre-Liquidação
     	   UPDATE der_ce_financeiro_imposto.pre_liquidacoes
  	 	      SET valor_medido_pi = NEW.valor_medido
  	 	    WHERE id              = NEW.id_pre_liquidacao;            
        ELSE -- Se Medição Já foi Validada 
           NEW.valor_medido = OLD.valor_medido; -- Não Permite alteração no valor
        END IF;
     END IF;
    
     -- ------------------------------------------------------------------------
     -- Se Medição ZERO Esta sendo PROTOCOLADA: Status De: 5-APT Para: 7-FEC
      IF OLD.id_status_fisico = 5 AND NEW.id_status_fisico = 7 THEN 
	    -- Exclui Pre-liquidação Gerada Automaticamente
        DELETE FROM der_ce_financeiro_imposto.pre_liquidacoes  
         WHERE id_tipo_origem   = 2 -- 2-Conserva
           AND id_despesa_origem= NEW.id;
     END IF;
    
  	 -- ---------------------------------------------------------------------
     -- Se Houve Altersção no [Valor de Reajuste] Atualiza total do reajuste do Contrato 
     IF NEW.valor_reajuste <> OLD.valor_reajuste THEN
          -- Calcula Total Reajuste registradado em medição de Contrato Conserva
		  SELECT sum(mco.valor_reajuste + mco.valor_ajuste_contratual) INTO tot_reajuste_medicao
		    FROM controle_conservacao.medicoes mco
		   WHERE mco.id_contrato = NEW.id_contrato
		   GROUP BY mco.id_contrato;
		  
		  -- Calcula Total Reajuste registradado em despesa com contrato
		  SELECT sum(dco.valor_despesa) INTO tot_reajuste_despesa
		    FROM der_ce_contrato_despesas.despesas_contrato dco
		   WHERE dco.id_contrato = NEW.id_contrato      -- Despesa de um mesmo Contrato
		     AND (dco.id_status>=3 AND dco.id_status<=7) -- Encaminhadas para o financeiro
		     AND (dco.id_tipo   =1  OR dco.id_tipo   =2) -- (1-Reajuste fora do padrão) ou (2-Diferença de reajuste)
		   GROUP BY dco.id_contrato;
		
		  tot_reajuste = COALESCE(tot_reajuste_medicao,0) + COALESCE(tot_reajuste_despesa,0);
		
		  -- Atualiza valor calculado na tabela de contrato
		  UPDATE der_ce_contrato.contratos
		     SET total_reajuste = tot_reajuste
		   WHERE id             = NEW.id_contrato;
     END IF;

  ELSEIF TG_OP = 'DELETE' THEN
     -- Nada a executar
  END IF;
  RETURN NULL;
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER;
-- -----------------------------------------------------------------------------
-- TRIGGER:  tg_con_tga_medicoes
-- -----------------------------------------------------------------------------
CREATE TRIGGER                      tg_con_tga_medicoes
AFTER INSERT OR UPDATE OR DELETE ON controle_conservacao.medicoes
FOR EACH ROW EXECUTE PROCEDURE      controle_conservacao.fn_con_tga_medicoes();
-- =============================================================================
-- FIM: Alterações nas trigger AFTER controle_conservacao.medicoes
-- =============================================================================


-- =============================================================================
--
-- FIM: C R I A Ç Â O   d a s   T R I G G E R S   e   F U N C T I O N S
--
-- =============================================================================


-- -----------------------------------------------------------------------------
-- FUNÇÂO....: controle_conservacao.fn_con_listar_documentos_medicao_conserva()
-- OBJETIVO..: Retornar uma lista de documentos digitais referenete a medição de conserva
-- PARAMETROS: var_id_medicao        -> Indica a medição a ser considerada
--             var_id_ponto_controle -> Indica o ponto de controle a ser considerado
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_listar_documentos_medicao_conserva (
  var_id_medicao        integer,
  var_id_ponto_controle integer
)
RETURNS TABLE (
  id                       INTEGER,
  nome_documento           TEXT,
  obrigatorio              BOOLEAN,
  situacao_envio           TEXT,
  cor_situacao_envio       TEXT,
  situacao_assinatura      TEXT,
  cor_situacao_assinatura  TEXT,
  situacao_conferencia     TEXT,
  cor_situacao_conferencia TEXT,
  multiple                 BOOLEAN,
  accept                   TEXT,
  reenvio                  BOOLEAN,
  id_entidade              TEXT,
  id_entidade_coleta       TEXT,
  id_tipo_entidade_coleta  INTEGER,
  id_tipo_documento        INTEGER,
  observacao               TEXT,
  ocorrencia               TEXT,
  versiona                 BOOLEAN,
  extensao_alternativa     TEXT,
  download                 BOOLEAN,
  nome_arquivo             TEXT,
  id_ponto_controle        INTEGER
) AS
$body$
BEGIN 
  RETURN QUERY	
  SELECT
	doc.id,
	ltd.descricao::text  AS nome_documento,
	CASE WHEN mva.id IN (10, 11) 
         THEN false ELSE TRUE
	END            AS obrigatorio,
    -- Mapeamento da Situação do Envio do documento
	CASE WHEN doc.id IS NOT NULL     THEN sva.descricao
		 WHEN mva.id NOT IN (10, 11) THEN 'Requer Envio'  
		                             ELSE 'Não Requer Envio'
	end::text            AS situacao_envio,
	CASE WHEN sva.id IS NOT NULL     THEN 'green'
	 	 WHEN mva.id NOT IN (10, 11) THEN 'red'
                     		         ELSE '#373435'
	end::text            AS cor_situacao_envio,
    -- Mapeamento da Situação da Assinatura
	CASE WHEN doc.id IS NOT NULL 
         THEN sad.descricao ELSE NULL
	end::text            AS situacao_assinatura,
	sad.cor::text        AS cor_situacao_assinatura,
    -- Mapeamento da Situação da Conferencia
	CASE WHEN doc.id IS NOT NULL
         THEN scd.descricao ELSE null
	end::text            AS situacao_conferencia,
	scd.cor::text        AS cor_situacao_conferencia,
    -- Caracteristicas do Documento
	false          AS multiple,
	tpa.media_type::text   AS accept,
	COALESCE(doc.id::bool, false) AS reenvio,
    -- Id´s relevantes
	var_id_medicao::text AS id_entidade,
	var_id_medicao::text AS id_entidade_coleta,
	122                  AS id_tipo_entidade_coleta,
	ltd.id               AS id_tipo_documento,
    -- Outras informações
	CASE WHEN doc.id IS NOT NULL 
         THEN doc.observacao	
		 ELSE ltd.descricao || ' - ( Contrato: ' || ctr.nr_contrato_der || ' Med.Nr.: ' || med.nr_medicao || ')'
	END            AS observacao,
	''::text       AS ocorrencia,
	false          AS versiona,
	null::text     AS extensao_alternativa,
	true           AS download,
	doc.nome_arquivo::TEXT,
    pce.id AS id_ponto_entidade
  FROM documento_digital.vw_lista_tipo_documento             ltd
  JOIN documento_digital.ponto_controle_x_tipo_doc           pxt ON pxt.id_tipo_documento  = ltd.id
  LEFT JOIN documento_digital.mapeamento_validacao           mva ON mva.id = pxt.id_requer_envio
  LEFT JOIN documento_digital.documentos_digitais            doc ON doc.id_tipo_documento  = ltd.id 
                                                                AND doc.id_entidade_coleta = var_id_medicao::text
  LEFT JOIN documento_digital.ponto_controle_entidade        pce ON pce.id_entidade_doc    = doc.id_entidade_doc 
                                                                AND pce.id_ponto_controle  = pxt.id_ponto_controle
  LEFT JOIN documento_digital.documentos_digitais_validacoes ddv ON ddv.id_ponto_entidade  = pce.id 
                                                                AND ddv.id_tipo_documento  = pxt.id_tipo_documento
  LEFT JOIN documento_digital.status_validacao               sva ON sva.id = ddv.id_status_envio 
  LEFT JOIN documento_digital.status_assinatura_documento    sad ON sad.id = doc.id_assinado 
  LEFT JOIN documento_digital.status_conferencia_documento   scd ON scd.id = doc.id_conferido
  LEFT JOIN documento_digital.tipo_arquivo                   tpa ON tpa.id = doc.id_tipo_arquivo
  LEFT JOIN controle_conservacao.medicoes                    med ON med.id = var_id_medicao
  LEFT JOIN der_ce_contrato.contratos                        ctr ON ctr.id = med.id_contrato
  WHERE pxt.id_ponto_controle = var_id_ponto_controle
  ORDER BY ltd.nome_arquivo; 
  
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100 ROWS 1000;

   
   -- -----------------------------------------------------------------------------
-- FUNÇÂO....: documento_digital.fn_doc_qtd_pendencias_com_assinaturas_ou_rejeicoes()
-- OBJETIVO..: Retornar a quantidade de pendencias de assinaturas e/ou documentos Rejeitados
-- PARAMETROS: var_id_entidade       -> Indica a medição a ser considerada
--             var_id_tipo_entidade  -> Indica o tipo de medição a ser considerado (Obra/Conserva/...)
--             var_id_ponto_controle -> Indica o ponto de controle a ser considerado
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION documento_digital.fn_doc_qtd_pendencias_com_assinaturas_ou_rejeicoes (
  var_id_entidade       INTEGER,
  var_id_tipo_entidade  INTEGER,
  var_id_ponto_controle INTEGER
)
RETURNS INTEGER AS
$body$
DECLARE
   var_pendencias_com_assinaturas_ou_rejeicao INTEGER;
BEGIN   
   SELECT count(ddv.id) INTO var_pendencias_com_assinaturas_ou_rejeicao
     FROM documento_digital.entidade_doc                   etd 
     JOIN documento_digital.ponto_controle_entidade        pce ON etd.id = pce.id_entidade_doc   
     JOIN documento_digital.documentos_digitais_validacoes ddv ON pce.id = ddv.id_ponto_entidade
     JOIN documento_digital.documentos_digitais            doc ON doc.id = ddv.id_documento
    WHERE etd.id_entidade       = var_id_entidade::text 
      AND etd.id_tipo_entidade  = var_id_tipo_entidade 
      AND pce.id_ponto_controle = var_id_ponto_controle      
      AND (-- Pendencias com Assinatura: 31-[DANE]-(Doc. Ainda Não Enviado) ou 32-[DANA]-(Doc. Ainda Não Assinado)
           ddv.id_status_assinatura IN (31,32)  
        OR -- OU Pendencias com Rejeições de documentos: 5-documento Rejeitado   
           doc.id_conferido = 5 
          );  
  RETURN COALESCE(var_pendencias_com_assinaturas_ou_rejeicao,0);
END;
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100;

-- ================================================================================================   
-- FUNÇÃO..: fn_con_verificar_medicoes_aguardando_assinatura_conserva
-- OBJETIVO: Verificar se todos os documentod de medições [Aguardando Assinatura] foram Assinadas
--           Se cursor retornar algo processa registros retornados
--           Se cursor retornar vazio não processa nada
-- ================================================================================================
CREATE OR REPLACE FUNCTION controle_conservacao.fn_con_verificar_medicoes_aguardando_assinatura_conserva ()
RETURNS text AS
$body$
DECLARE
   var_qtd_processada   INTEGER;
   var_id_status_fisico INTEGER;
   var_obs_historico    text;
   var_msg_retorno      text;
   var_medicao          RECORD;
   -- Declara CURSOR a ser utilizado
   var_lista_medicoes  CURSOR FOR
				SELECT qry.id,
                       122 AS id_tipo_entidade, -- 122 - Medição da Conserva Rodoviaria 
                       qry.medicao_zero,
                       qry.qtd_pendencias = 0 AS sem_pendencia_com_assinaturas_ou_rejeicao
                  FROM (SELECT med.id, 
                               med.valor_medido = 0 AS medicao_zero,
                               CASE WHEN med.valor_medido = 0 
                                    THEN documento_digital.fn_doc_qtd_pendencias_com_assinaturas_ou_rejeicoes(med.id,122,12225) -- 12225-Antes de Protocolar Medição ZERO
                                    ELSE documento_digital.fn_doc_qtd_pendencias_com_assinaturas_ou_rejeicoes(med.id,122,12235) -- 11235-Antes de Protocolar Medição VALOR
                               END qtd_pendencias
                          FROM controle_conservacao.medicoes med
                         WHERE med.id_status_fisico = 3 -- 3-Aguardando Assinatura
                       ) qry
                WHERE qry.qtd_pendencias = 0;
BEGIN
    var_qtd_processada = 0;
    -- Abre o Cursos de mediçõs aptas para processar
	OPEN var_lista_medicoes;
	LOOP
        -- Para Cada Registro de medição recuperado
		FETCH var_lista_medicoes INTO var_medicao; -- Recupera um registro da lista
		EXIT WHEN NOT FOUND;                       -- Quando não existir mais sai do LOOP
        
        IF var_medicao.sem_pendencia_com_assinaturas_ou_rejeicao THEN
            -- Verifica Tipo de Medição
            IF var_medicao.medicao_zero THEN -- Se For Medição ZERO
               var_id_status_fisico = 5;     -- 5-Aguardando Protocolo
               var_obs_historico    = 'Documentos Medição ZERO Assinados!';
            ELSE                             -- Se For Medição com Valor
               var_id_status_fisico = 4;     -- 4-Aguardando Conferencia
               var_obs_historico    = 'Documentos Medição com VALOR Assinados!';
            END IF;
            
            -- Atualiza Status da Medição          
            UPDATE controle_conservacao.medicoes 
               SET id_status_fisico = var_id_status_fisico
             WHERE id = var_medicao.id;
             
            -- Gera Histórico da Alteração
            INSERT INTO controle_conservacao.medicoes_historicos
               (id_medicao, id_tipo_historico, matricula, observacao)
            VALUES (var_medicao.id, 8, 'SISTEMA', var_obs_historico);
            var_qtd_processada = var_qtd_processada + 1;
        END IF;
	END LOOP;
	CLOSE var_lista_medicoes;
    
    -- Prepara Mensagem de retorno
    SELECT CASE WHEN var_qtd_processada = 0 THEN 'Nenhuma Medição Foi Processada.'
                WHEN var_qtd_processada = 1 THEN '[Uma] Medição Foi Processada.'
                WHEN var_qtd_processada > 1 THEN '[' || var_qtd_processada || '] Medições Foram Processadas.'
           END AS msg_retorno
    INTO var_msg_retorno;
    	
    RETURN var_msg_retorno;
END
$body$
LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER COST 100;
               