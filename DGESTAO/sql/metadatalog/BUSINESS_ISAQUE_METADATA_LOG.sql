/*------ SYSDBA 29/01/2013 16:47:19 --------*/

COMMENT ON DOMAIN DMN_MONEY_DESCONTO IS 'Valor Desconto c/ 3 cadas decimais.';

CREATE DOMAIN DMN_MONEY_DESCONTO_4 AS
NUMERIC(15,4)
DEFAULT 0;COMMENT ON DOMAIN DMN_MONEY_DESCONTO_4 IS 'Valor Desconto c/ 4 cadas decimais.';




/*------ SYSDBA 29/01/2013 16:53:42 --------*/

CREATE DOMAIN DMN_PERCENTUAL_3 AS
NUMERIC(15,3)
DEFAULT 0;COMMENT ON DOMAIN DMN_PERCENTUAL_3 IS 'Percentual c/ 3 casas decimais.';

CREATE DOMAIN DMN_PERCENTUAL_2 AS
NUMERIC(15,2)
DEFAULT 0;COMMENT ON DOMAIN DMN_PERCENTUAL_2 IS 'Percentual c/ 2 casas decimais.';

CREATE DOMAIN DMN_PERCENTUAL_4 AS
NUMERIC(15,4)
DEFAULT 0;COMMENT ON DOMAIN DMN_PERCENTUAL_4 IS 'Percentual c/ 4 casas decimais.';




/*------ SYSDBA 29/01/2013 16:55:19 --------*/

COMMENT ON COLUMN TBVENDAS.DESCONTO IS
'Valor Total Desconto.';




/*------ SYSDBA 29/01/2013 16:55:46 --------*/

COMMENT ON COLUMN TBVENDAS.NFE_VALOR_DESCONTO IS
'NFe - Valor Total Desconto.';




/*------ SYSDBA 29/01/2013 16:56:39 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_PERCENTUAL_2'
where (RDB$FIELD_NAME = 'DESCONTO') and
(RDB$RELATION_NAME = 'TBVENDAS')
;

COMMENT ON COLUMN TBVENDAS.DESCONTO IS
'Valor Total Desconto.';




/*------ SYSDBA 29/01/2013 16:57:12 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_DESCONTO_4'
where (RDB$FIELD_NAME = 'DESCONTO') and
(RDB$RELATION_NAME = 'TBVENDAS')
;

COMMENT ON COLUMN TBVENDAS.DESCONTO IS
'Valor Total Desconto.';




/*------ SYSDBA 29/01/2013 16:59:39 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY'
where (RDB$FIELD_NAME = 'DESCONTO') and
(RDB$RELATION_NAME = 'TBVENDAS')
;

COMMENT ON COLUMN TBVENDAS.DESCONTO IS
'Valor Total Desconto.';




/*------ SYSDBA 29/01/2013 17:00:14 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_PERCENTUAL_3'
where (RDB$FIELD_NAME = 'DESCONTO') and
(RDB$RELATION_NAME = 'TVENDASITENS')
;

COMMENT ON COLUMN TVENDASITENS.DESCONTO IS
'Percentual desconto.';




/*------ SYSDBA 29/01/2013 17:00:25 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_DESCONTO_4'
where (RDB$FIELD_NAME = 'DESCONTO_VALOR') and
(RDB$RELATION_NAME = 'TVENDASITENS')
;

COMMENT ON COLUMN TVENDASITENS.DESCONTO_VALOR IS
'Valor desconto (Unitario).';




/*------ SYSDBA 30/01/2013 16:07:12 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_DESCONTO_4'
where (RDB$FIELD_NAME = 'DESCONTO') and
(RDB$RELATION_NAME = 'TBVENDAS')
;

COMMENT ON COLUMN TBVENDAS.DESCONTO IS
'Valor Total Desconto.';




/*------ SYSDBA 30/01/2013 16:09:02 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money_desconto_4;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.Qtde, 0) * coalesce(i.Punit, 0) )
    --, sum( coalesce(i.Qtde, 0) * (coalesce(i.Punit, 0) - coalesce(i.Pfinal, 0)) )
    , sum( coalesce(i.Qtde, 0) * coalesce(i.desconto_valor, 0) )
  from TVENDASITENS i
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);

  Update TBVENDAS v Set
      v.Desconto = :Total_desconto
    , v.Totalvenda = :Total_bruto - :Total_desconto
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end
^

SET TERM ; ^


/*------ SYSDBA 06/02/2013 01:23:14 --------*/

COMMENT ON COLUMN TBVENDAS.STATUS IS
'Status:
1 - Em Atendimento
2 - Aberta
3 - Finalizada
4 - NF-e emitida
5 - Cancelada';




/*------ SYSDBA 07/02/2013 16:37:51 --------*/

CREATE DOMAIN DMN_MONEY_4 AS
NUMERIC(15,4);


/*------ SYSDBA 07/02/2013 16:46:12 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY'
where (RDB$FIELD_NAME = 'PFINAL') and
(RDB$RELATION_NAME = 'TVENDASITENS')
;

COMMENT ON COLUMN TVENDASITENS.PFINAL IS
'';



/*------ 08/02/2013 14:15:51 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money_desconto_4;
  declare variable total_liquido Dmn_money;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.Qtde, 0) * coalesce(i.Punit, 0) )
    --, sum( coalesce(i.Qtde, 0) * (coalesce(i.Punit, 0) - coalesce(i.Pfinal, 0)) )
    , sum( coalesce(i.Qtde, 0) * coalesce(i.desconto_valor, 0) )
    , sum( coalesce(i.Qtde, 0) * coalesce(i.pfinal, 0) )
  from TVENDASITENS i
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto
    , total_liquido;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);

  Update TBVENDAS v Set
      v.Desconto = :Total_desconto
--    , v.Totalvenda = :Total_bruto - :Total_desconto
    , v.Totalvenda = :Total_liquido
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end^

/*------ 08/02/2013 14:15:51 --------*/

SET TERM ; ^


/*------ SYSDBA 08/02/2013 14:49:19 --------*/

COMMENT ON COLUMN TBNFE_ENVIADA.DATAEMISSAO IS
'Data Emissao.';




/*------ SYSDBA 08/02/2013 14:49:30 --------*/

COMMENT ON COLUMN TBNFE_ENVIADA.HORAEMISSAO IS
'Hora Emissao.';




/*------ SYSDBA 08/02/2013 14:50:42 --------*/

COMMENT ON COLUMN TBNFE_ENVIADA.SERIE IS
'Serie da NF-e.';

COMMENT ON COLUMN TBNFE_ENVIADA.NUMERO IS
'Numero da NF-e.';

COMMENT ON COLUMN TBNFE_ENVIADA.CHAVE IS
'Chave.';

COMMENT ON COLUMN TBNFE_ENVIADA.PROTOCOLO IS
'Protocolo.';

COMMENT ON COLUMN TBNFE_ENVIADA.RECIBO IS
'Numero Recibo.';

COMMENT ON COLUMN TBNFE_ENVIADA.XML_FILENAME IS
'Nome arquivo XML.';

COMMENT ON COLUMN TBNFE_ENVIADA.XML_FILE IS
'Arquivo XML.';

COMMENT ON COLUMN TBNFE_ENVIADA.LOTE_ANO IS
'Ano Lote.';

COMMENT ON COLUMN TBNFE_ENVIADA.LOTE_NUM IS
'Numero Lote.';




/*------ SYSDBA 08/02/2013 14:51:22 --------*/

COMMENT ON COLUMN TBVENDAS.VENDA_PRAZO IS
'Venda A Prazo:
0 - Nao
1 - Sim';




/*------ SYSDBA 08/02/2013 14:52:12 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_VCHAR_50'
where (RDB$FIELD_NAME = 'CANCEL_USUARIO') and
(RDB$RELATION_NAME = 'TBVENDAS')
;

COMMENT ON COLUMN TBVENDAS.CANCEL_USUARIO IS
'';



/*------ 14/02/2013 08:52:40 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_CONTA_CORRENTE_SALDO (
    CONTA_CORRENTE integer,
    DATA_MOVIMENTO date)
as
declare variable DATA_SALDO_ANT date;
declare variable VALOR_SALDO_ANT numeric(15,2);
declare variable TOTAL_CREDITO_DIA numeric(15,2);
declare variable TOTAL_DEBITO_DIA numeric(15,2);
declare variable TOTAL_SALDO_DIA numeric(15,2);
begin
  -- Buscar Saldo anterior
  Select
      s1.Data_saldo
    , s1.Valor_saldo
  from TBCONTA_CORRENTE_SALDO s1
  where s1.Codigo = :Conta_corrente
    and s1.Data_saldo in (
      Select
        max(s2.Data_saldo)
      from TBCONTA_CORRENTE_SALDO s2
      where s2.Codigo = :Conta_corrente
        and s2.Data_saldo < :Data_movimento
    )
  into
      Data_saldo_ant
    , Valor_saldo_ant;

  -- Gravar Saldo anterior caso nao exista
  if ( :Data_saldo_ant is null ) then
  begin
    Data_saldo_ant  = :Data_movimento - 1;
    Valor_saldo_ant = 0;

    Insert Into TBCONTA_CORRENTE_SALDO (
        Codigo
      , Data_saldo
      , Valor_saldo
    ) values (
        :Conta_corrente
      , :Data_saldo_ant
      , :Valor_saldo_ant
    );
  end 

  -- Consolidar Creditos e Debitos do dia
  Select
      sum( Case when upper(m.Tipo) = 'C' then m.Valor else 0 end )
    , sum( Case when upper(m.Tipo) = 'D' then m.Valor else 0 end )
  from TBCAIXA_MOVIMENTO m
  where m.Situacao = 1 -- Confirmado
    and m.Conta_corrente = :Conta_corrente
    and cast(m.Datahora as Date ) = :Data_movimento
  into
      Total_credito_dia
    , Total_debito_dia;

  Total_saldo_dia = :Valor_saldo_ant + coalesce(:Total_credito_dia, 0) - coalesce(:Total_debito_dia, 0);

  /* Gerar Saldo Conta Corrente do Dia */
  if ( not Exists(
    Select
      s3.Codigo
    from TBCONTA_CORRENTE_SALDO s3
    where s3.Codigo = :Conta_corrente
      and s3.Data_saldo = :Data_movimento
  ) ) then
  begin

    -- Inserir Saldo do Dia
    Insert Into TBCONTA_CORRENTE_SALDO (
        Codigo
      , Data_saldo
      , Valor_saldo
    ) values (
        :Conta_corrente
      , :Data_movimento
      , :Total_saldo_dia
    );

   end
   else
   begin

     -- Atualizar Saldo do Dia
     Update TBCONTA_CORRENTE_SALDO s Set
       s.Valor_saldo = :Total_saldo_dia
     where s.Codigo = :Conta_corrente
       and s.Data_saldo = :Data_movimento;

   end 
end^

/*------ 14/02/2013 08:52:40 --------*/

SET TERM ; ^

/*------ 14/02/2013 08:53:25 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure GET_DIA_UTIL (
    DATA date,
    DIAS integer)
returns (
    DIA_UTIL date)
as
begin
  Dia_util = :Data + :Dias;
  if ( Extract(Weekday from :Dia_util) = 0 ) then /* Caso seja domingo */
    Dia_util = :Dia_util + 1;
  else
  if ( Extract(Weekday from :Dia_util) = 6 ) then /* Caso seja sabado */
    Dia_util = :Dia_util + 2;

  suspend;
end^

/*------ 14/02/2013 08:53:25 --------*/

SET TERM ; ^


/*------ SYSDBA 14/02/2013 09:02:40 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_cancelar for tbvendas
active after update position 2
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 5)) then
  begin

    -- Retornar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , valor_produto
    do
    begin
      estoque = :Estoque + :Quantidade;

      -- Retornar estoque
      Update TBPRODUTO p Set
        p.Qtde = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - VENDA CANCELADA'
        , Current_time
        , :Estoque - :Quantidade
        , :Quantidade
        , :Estoque
        , new.Cancel_usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );

    end

    -- Cancelar Contas A Receber (Apenas parcelas nao pagas)
    Update TBCONTREC r Set
        r.status   = 'CANCELADA'
      , r.Situacao = 0 -- Cancelado
    where r.anovenda = new.ano
      and r.numvenda = new.codcontrol
      and coalesce(r.Valorrectot, 0) = 0;

    -- Cancelar Movimento Caixa
    Update TBCAIXA_MOVIMENTO m Set
      m.Situacao = 0 -- Cancelado
    where m.Empresa = new.Codemp
      and m.Cliente = new.Codcli
      and m.Venda_ano = new.Ano
      and m.Venda_num = new.Codcontrol;
     
  end 
end
^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 09:02:51 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_atualizar_estoque for tbvendas
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable reserva integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then
  begin

    -- Baixar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Reserva, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , reserva
        , valor_produto
    do
    begin
      reserva = :reserva - :Quantidade;
      estoque = :Estoque - :Quantidade;

      -- Baixar estoque
      Update TBPRODUTO p Set
          p.Reserva = :Reserva
        , p.Qtde    = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TVENDASITENS i Set
        i.Qtdefinal = :Estoque
      where i.Ano        = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - VENDA'
        , Current_time
        , :Estoque + :Quantidade
        , :Quantidade
        , :Estoque
        , new.Usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );
    end
     
  end 
end
^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 09:03:11 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money_desconto_4;
  declare variable total_liquido Dmn_money;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.Qtde, 0) * coalesce(i.Punit, 0) )
    , sum( coalesce(i.Qtde, 0) * coalesce(i.desconto_valor, 0) )
    , sum( coalesce(i.Qtde, 0) * coalesce(i.pfinal, 0) )
  from TVENDASITENS i
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto
    , total_liquido;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);

  Update TBVENDAS v Set
      v.Desconto   = :Total_desconto
    , v.Totalvenda = :Total_liquido
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end
^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 09:04:47 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_compras_cancelar for tbcompras
active after update position 2
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_compra numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then
  begin

    -- Decrementar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
    do
    begin
      -- Decrementar estoque
      Update TBPRODUTO p Set
        p.Qtde       = :Estoque - :Quantidade
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - COMPRA CANCELADA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque - :Quantidade
        , new.Cancel_usuario
        , 'Custo Final no valor de R$ ' || :Custo_compra
      );
    end
     
    -- Cancelar Movimento Caixa
    Update TBCAIXA_MOVIMENTO m Set
      m.Situacao = 0 -- Cancelado
    where m.Empresa = new.Codemp
      and m.Fornecedor = new.Codforn
      and m.Compra_ano = new.Ano
      and m.Compra_num = new.Codcontrol;

  end 
end
^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 09:05:03 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_compras_atualizar_estoque for tbcompras
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_produto numeric(15,2);
  declare variable custo_compra numeric(15,2);
  declare variable custo_medio numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 2)) then
  begin

    -- Incrimentar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
        , coalesce(p.Customedio, 0)
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
        , Custo_produto
    do
    begin
      if ( (:Custo_compra > 0) and (:Custo_produto > 0) and (:Estoque > 0) ) then
        Custo_medio = (:Custo_compra + :Custo_produto) / 2;
      else
        Custo_medio = :Custo_compra;

      -- Incrementar estoque
      Update TBPRODUTO p Set
          --p.Customedio = :Custo_medio
          p.Customedio = :Custo_compra
        , p.Qtde       = :Estoque + :Quantidade
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TBCOMPRASITENS i Set
          i.Qtdeantes = :Estoque
        , i.Qtdefinal = :Estoque + :Quantidade
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - COMPRA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque + :Quantidade
        , new.Usuario
        , 'Custo Medio no valor de R$ ' || :Custo_medio
      );
    end
     
  end 
end
^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 09:48:51 --------*/

ALTER TABLE TVENDASITENS
    ADD TOTAL_BRUTO DMN_MONEY,
    ADD TOTAL_DESCONTO DMN_MONEY,
    ADD TOTAL_LIQUIDO DMN_MONEY;

COMMENT ON COLUMN TVENDASITENS.TOTAL_BRUTO IS
'Total Bruto.';

COMMENT ON COLUMN TVENDASITENS.TOTAL_DESCONTO IS
'Total Desconto.';

COMMENT ON COLUMN TVENDASITENS.TOTAL_LIQUIDO IS
'Total Liquido.';




/*------ SYSDBA 14/02/2013 09:50:37 --------*/

SET TERM ^ ;

CREATE trigger tg_vendasitens_totais_produto for tvendasitens
active before insert or update position 0
AS
begin
  new.total_bruto    = coalesce(new.qtde, 0) * coalesce(new.punit, 0);
  new.total_desconto = coalesce(new.qtde, 0) * coalesce(new.desconto_valor, 0);
  new.total_liquido  = coalesce(new.qtde, 0) * coalesce(new.pfinal, 0);
end^

SET TERM ; ^


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 35, column 7.
amd.

*/



/*------ SYSDBA 14/02/2013 10:34:24 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_totais_produto for tvendasitens
active before insert or update position 0
AS
begin
  new.total_bruto    = ( coalesce(new.qtde, 0) * coalesce(new.punit, 0) );
  new.total_desconto = ( coalesce(new.qtde, 0) * coalesce(new.desconto_valor, 0) );
  new.total_liquido  = ( coalesce(new.total_bruto, 0) - coalesce(new.total_desconto, 0) );
end^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 10:46:47 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money;
  declare variable total_liquido Dmn_money;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.total_bruto,    0) )
    , sum( coalesce(i.total_desconto, 0) )
  from TVENDASITENS i
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);
  total_liquido  = :Total_bruto - :Total_desconto;

  Update TBVENDAS v Set
      v.Desconto   = :Total_desconto
    , v.Totalvenda = :Total_liquido
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 11:13:26 --------*/

ALTER TABLE TBVENDAS
    ADD TOTALVENDA_BRUTA DMN_MONEY;

COMMENT ON COLUMN TBVENDAS.TOTALVENDA_BRUTA IS
'Total Venda Bruta.';

alter table TBVENDAS
alter ANO position 1;

alter table TBVENDAS
alter CODCONTROL position 2;

alter table TBVENDAS
alter CODEMP position 3;

alter table TBVENDAS
alter CODCLI position 4;

alter table TBVENDAS
alter DTVENDA position 5;

alter table TBVENDAS
alter STATUS position 6;

alter table TBVENDAS
alter TOTALVENDA_BRUTA position 7;

alter table TBVENDAS
alter DESCONTO position 8;

alter table TBVENDAS
alter TOTALVENDA position 9;

alter table TBVENDAS
alter DTFINALIZACAO_VENDA position 10;

alter table TBVENDAS
alter OBS position 11;

alter table TBVENDAS
alter FORMAPAG position 12;

alter table TBVENDAS
alter FATDIAS position 13;

alter table TBVENDAS
alter SERIE position 14;

alter table TBVENDAS
alter NFE position 15;

alter table TBVENDAS
alter DATAEMISSAO position 16;

alter table TBVENDAS
alter HORAEMISSAO position 17;

alter table TBVENDAS
alter CFOP position 18;

alter table TBVENDAS
alter VERIFICADOR_NFE position 19;

alter table TBVENDAS
alter XML_NFE position 20;

alter table TBVENDAS
alter VENDEDOR_COD position 21;

alter table TBVENDAS
alter USUARIO position 22;

alter table TBVENDAS
alter FORMAPAGTO_COD position 23;

alter table TBVENDAS
alter CONDICAOPAGTO_COD position 24;

alter table TBVENDAS
alter VENDA_PRAZO position 25;

alter table TBVENDAS
alter PRAZO_01 position 26;

alter table TBVENDAS
alter PRAZO_02 position 27;

alter table TBVENDAS
alter PRAZO_03 position 28;

alter table TBVENDAS
alter PRAZO_04 position 29;

alter table TBVENDAS
alter PRAZO_05 position 30;

alter table TBVENDAS
alter PRAZO_06 position 31;

alter table TBVENDAS
alter PRAZO_07 position 32;

alter table TBVENDAS
alter PRAZO_08 position 33;

alter table TBVENDAS
alter PRAZO_09 position 34;

alter table TBVENDAS
alter PRAZO_10 position 35;

alter table TBVENDAS
alter PRAZO_11 position 36;

alter table TBVENDAS
alter PRAZO_12 position 37;

alter table TBVENDAS
alter LOTE_NFE_ANO position 38;

alter table TBVENDAS
alter LOTE_NFE_NUMERO position 39;

alter table TBVENDAS
alter NFE_ENVIADA position 40;

alter table TBVENDAS
alter CANCEL_USUARIO position 41;

alter table TBVENDAS
alter CANCEL_DATAHORA position 42;

alter table TBVENDAS
alter CANCEL_MOTIVO position 43;

alter table TBVENDAS
alter XML_NFE_FILENAME position 44;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS position 45;

alter table TBVENDAS
alter NFE_VALOR_ICMS position 46;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS_SUBST position 47;

alter table TBVENDAS
alter NFE_VALOR_ICMS_SUBST position 48;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_PRODUTO position 49;

alter table TBVENDAS
alter NFE_VALOR_FRETE position 50;

alter table TBVENDAS
alter NFE_VALOR_SEGURO position 51;

alter table TBVENDAS
alter NFE_VALOR_DESCONTO position 52;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_II position 53;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_IPI position 54;

alter table TBVENDAS
alter NFE_VALOR_PIS position 55;

alter table TBVENDAS
alter NFE_VALOR_COFINS position 56;

alter table TBVENDAS
alter NFE_VALOR_OUTROS position 57;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_NOTA position 58;




/*------ SYSDBA 14/02/2013 11:14:17 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money;
  declare variable total_liquido Dmn_money;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.total_bruto,    0) )
    , sum( coalesce(i.total_desconto, 0) )
  from TVENDASITENS i
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);
  total_liquido  = :Total_bruto - :Total_desconto;

  Update TBVENDAS v Set
      v.Totalvenda_bruta = :Total_bruto
    , v.Desconto   = :Total_desconto
    , v.Totalvenda = :Total_liquido
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end^

SET TERM ; ^




/*------ SYSDBA 14/02/2013 11:32:21 --------*/

COMMENT ON COLUMN TBVENDAS.TOTALVENDA_BRUTA IS
'Total Venda Bruta (Total Produto).';




/*------ SYSDBA 14/02/2013 11:32:37 --------*/

COMMENT ON COLUMN TBVENDAS.TOTALVENDA_BRUTA IS
'Valor Total Venda Bruta (Total Produto).';




/*------ SYSDBA 14/02/2013 11:33:23 --------*/

COMMENT ON COLUMN TBVENDAS.TOTALVENDA IS
'Valor Total Venda Liquida (Total Nota, na maioria dos casos).';




/*------ SYSDBA 29/04/2013 18:25:50 --------*/

ALTER TABLE TBFORNECEDOR
    ADD TRANSPORTADORA DMN_LOGICO DEFAULT 0;

COMMENT ON COLUMN TBFORNECEDOR.TRANSPORTADORA IS
'Transportadora:
0 - Nao
1 - Sim';




/*------ SYSDBA 01/05/2013 19:18:22 --------*/

ALTER TABLE TBVENDAS
    ADD NFE_MODALIDADE_FRETE DMN_SMALLINT_NN,
    ADD NFE_TRANSPORTADORA DMN_INTEGER_N;

COMMENT ON COLUMN TBVENDAS.NFE_MODALIDADE_FRETE IS
'Modalidade Frete:
0 -  (0) Por conta do Emitente
1 -  (1) Por conta do Destinatario
2 -  (2) Por conta de Terceiros
3 -  (9) Sem Frete';

COMMENT ON COLUMN TBVENDAS.NFE_TRANSPORTADORA IS
'Transportadora:

Codigo do Fornecedor do Servico de Transporte.';




/*------ SYSDBA 01/05/2013 19:18:44 --------*/

ALTER TABLE TBVENDAS ADD IBE$$TEMP_COLUMN
 SMALLINT DEFAULT 3
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBVENDAS') AND
      (F1.RDB$FIELD_NAME = 'NFE_MODALIDADE_FRETE');

ALTER TABLE TBVENDAS DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column ANO position 1;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CODCONTROL position 2;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CODEMP position 3;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CODCLI position 4;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column DTVENDA position 5;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column STATUS position 6;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column TOTALVENDA_BRUTA position 7;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column DESCONTO position 8;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column TOTALVENDA position 9;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column DTFINALIZACAO_VENDA position 10;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column OBS position 11;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column FORMAPAG position 12;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column FATDIAS position 13;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column SERIE position 14;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE position 15;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column DATAEMISSAO position 16;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column HORAEMISSAO position 17;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CFOP position 18;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column VERIFICADOR_NFE position 19;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column XML_NFE position 20;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column VENDEDOR_COD position 21;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column USUARIO position 22;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column FORMAPAGTO_COD position 23;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CONDICAOPAGTO_COD position 24;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column VENDA_PRAZO position 25;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_01 position 26;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_02 position 27;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_03 position 28;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_04 position 29;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_05 position 30;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_06 position 31;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_07 position 32;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_08 position 33;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_09 position 34;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_10 position 35;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_11 position 36;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column PRAZO_12 position 37;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column LOTE_NFE_ANO position 38;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column LOTE_NFE_NUMERO position 39;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_ENVIADA position 40;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CANCEL_USUARIO position 41;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CANCEL_DATAHORA position 42;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column CANCEL_MOTIVO position 43;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column XML_NFE_FILENAME position 44;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_MODALIDADE_FRETE position 45;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_TRANSPORTADORA position 46;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_BASE_ICMS position 47;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_ICMS position 48;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_BASE_ICMS_SUBST position 49;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_ICMS_SUBST position 50;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_TOTAL_PRODUTO position 51;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_FRETE position 52;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_SEGURO position 53;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_DESCONTO position 54;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_TOTAL_II position 55;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_TOTAL_IPI position 56;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_PIS position 57;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_COFINS position 58;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_OUTROS position 59;


/*------ SYSDBA 01/05/2013 19:19:04 --------*/

alter table TBVENDAS
alter column NFE_VALOR_TOTAL_NOTA position 60;


/*------ SYSDBA 01/05/2013 19:40:14 --------*/

COMMENT ON COLUMN TBVENDAS.NFE_MODALIDADE_FRETE IS
'Modalidade Frete:
0 -  (0) Por conta do Emitente               [CIF - (Cost, Insurance and Freight - �Custo, Seguros e Frete�)]
1 -  (1) Por conta do Destinatario/Remetente [FOB - (Free on Board - �Livre a bordo�)]
2 -  (2) Por conta de Terceiros
3 -  (9) Sem Frete';




/*------ SYSDBA 01/05/2013 19:48:22 --------*/

ALTER TABLE TBVENDAS
    ADD NFE_PLACA_VEICULO DMN_VCHAR_10,
    ADD NFE_PLACA_UF DMN_VCHAR_02,
    ADD NFE_PLACA_RNTC DMN_VCHAR_10;

COMMENT ON COLUMN TBVENDAS.NFE_PLACA_VEICULO IS
'Placa do Veiculo de Transporte.';

COMMENT ON COLUMN TBVENDAS.NFE_PLACA_UF IS
'UF da Placa do Veiculo.';

COMMENT ON COLUMN TBVENDAS.NFE_PLACA_RNTC IS
'RNCT do Veiculo.

RNTC - Registros Nacional de Transportes de Carga (Identificacao do vagao quando o transporte for Trem)';

alter table TBVENDAS
alter ANO position 1;

alter table TBVENDAS
alter CODCONTROL position 2;

alter table TBVENDAS
alter CODEMP position 3;

alter table TBVENDAS
alter CODCLI position 4;

alter table TBVENDAS
alter DTVENDA position 5;

alter table TBVENDAS
alter STATUS position 6;

alter table TBVENDAS
alter TOTALVENDA_BRUTA position 7;

alter table TBVENDAS
alter DESCONTO position 8;

alter table TBVENDAS
alter TOTALVENDA position 9;

alter table TBVENDAS
alter DTFINALIZACAO_VENDA position 10;

alter table TBVENDAS
alter OBS position 11;

alter table TBVENDAS
alter FORMAPAG position 12;

alter table TBVENDAS
alter FATDIAS position 13;

alter table TBVENDAS
alter SERIE position 14;

alter table TBVENDAS
alter NFE position 15;

alter table TBVENDAS
alter DATAEMISSAO position 16;

alter table TBVENDAS
alter HORAEMISSAO position 17;

alter table TBVENDAS
alter CFOP position 18;

alter table TBVENDAS
alter VERIFICADOR_NFE position 19;

alter table TBVENDAS
alter XML_NFE position 20;

alter table TBVENDAS
alter VENDEDOR_COD position 21;

alter table TBVENDAS
alter USUARIO position 22;

alter table TBVENDAS
alter FORMAPAGTO_COD position 23;

alter table TBVENDAS
alter CONDICAOPAGTO_COD position 24;

alter table TBVENDAS
alter VENDA_PRAZO position 25;

alter table TBVENDAS
alter PRAZO_01 position 26;

alter table TBVENDAS
alter PRAZO_02 position 27;

alter table TBVENDAS
alter PRAZO_03 position 28;

alter table TBVENDAS
alter PRAZO_04 position 29;

alter table TBVENDAS
alter PRAZO_05 position 30;

alter table TBVENDAS
alter PRAZO_06 position 31;

alter table TBVENDAS
alter PRAZO_07 position 32;

alter table TBVENDAS
alter PRAZO_08 position 33;

alter table TBVENDAS
alter PRAZO_09 position 34;

alter table TBVENDAS
alter PRAZO_10 position 35;

alter table TBVENDAS
alter PRAZO_11 position 36;

alter table TBVENDAS
alter PRAZO_12 position 37;

alter table TBVENDAS
alter LOTE_NFE_ANO position 38;

alter table TBVENDAS
alter LOTE_NFE_NUMERO position 39;

alter table TBVENDAS
alter NFE_ENVIADA position 40;

alter table TBVENDAS
alter CANCEL_USUARIO position 41;

alter table TBVENDAS
alter CANCEL_DATAHORA position 42;

alter table TBVENDAS
alter CANCEL_MOTIVO position 43;

alter table TBVENDAS
alter XML_NFE_FILENAME position 44;

alter table TBVENDAS
alter NFE_MODALIDADE_FRETE position 45;

alter table TBVENDAS
alter NFE_TRANSPORTADORA position 46;

alter table TBVENDAS
alter NFE_PLACA_VEICULO position 47;

alter table TBVENDAS
alter NFE_PLACA_UF position 48;

alter table TBVENDAS
alter NFE_PLACA_RNTC position 49;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS position 50;

alter table TBVENDAS
alter NFE_VALOR_ICMS position 51;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS_SUBST position 52;

alter table TBVENDAS
alter NFE_VALOR_ICMS_SUBST position 53;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_PRODUTO position 54;

alter table TBVENDAS
alter NFE_VALOR_FRETE position 55;

alter table TBVENDAS
alter NFE_VALOR_SEGURO position 56;

alter table TBVENDAS
alter NFE_VALOR_DESCONTO position 57;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_II position 58;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_IPI position 59;

alter table TBVENDAS
alter NFE_VALOR_PIS position 60;

alter table TBVENDAS
alter NFE_VALOR_COFINS position 61;

alter table TBVENDAS
alter NFE_VALOR_OUTROS position 62;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_NOTA position 63;




/*------ SYSDBA 01/05/2013 20:10:03 --------*/

create view vw_modalidade_frete ( codigo, descricao )
as

Select First 1
    0
  , '(0) Por conta do Emitente [CIF]'
from TBEMPRESA

union

Select First 1
    1
  , '(1) Por conta do Destinatario/Remetente [FOB]'
from TBEMPRESA

union

Select First 1
    3
  , '(9) Sem Frete'
from TBEMPRESA
;

GRANT ALL ON VW_MODALIDADE_FRETE TO "PUBLIC";

/*------ SYSDBA 01/05/2013 20:25:35 --------*/

update TBVENDAS v set v.nfe_modalidade_frete = 3 where v.nfe_modalidade_frete is null;
/*------ SYSDBA 01/05/2013 20:25:47 --------*/

COMMIT WORK;

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 53, column 34.
,.

*/



/*------ SYSDBA 06/05/2013 21:32:58 --------*/

CREATE TABLE TBVENDAS_VOLUME (
    ANO_VENDA DMN_SMALLINT_NN NOT NULL,
    CONTROLE_VENDA DMN_INTEGER_NN NOT NULL,
    SEQUENCIAL DMN_SMALLINT_NN NOT NULL,
    NUMERO DMN_VCHAR_50,
    QUANTIDADE DMN_SMALLINT_NN DEFAULT 1,
    ESPECIE DMN_VCHAR_50,
    MARCA DMN_VCHAR_50,
    PESO_BRUTO DMN_PERCENTUAL_3,
    PESO_LIQUIDO DMN_PERCENTUAL_3);

ALTER TABLE TBVENDAS_VOLUME
ADD CONSTRAINT PK_TBVENDAS_VOLUME
PRIMARY KEY (ANO_VENDA,CONTROLE_VENDA,SEQUENCIAL);

COMMENT ON COLUMN TBVENDAS_VOLUME.ANO_VENDA IS
'Ano Venda.';

COMMENT ON COLUMN TBVENDAS_VOLUME.CONTROLE_VENDA IS
'Controle Venda.';

COMMENT ON COLUMN TBVENDAS_VOLUME.SEQUENCIAL IS
'Sequencial.';

COMMENT ON COLUMN TBVENDAS_VOLUME.NUMERO IS
'Numero Volume.';

COMMENT ON COLUMN TBVENDAS_VOLUME.QUANTIDADE IS
'Quantidade Total de Volumes.';

COMMENT ON COLUMN TBVENDAS_VOLUME.ESPECIE IS
'Especie.';

COMMENT ON COLUMN TBVENDAS_VOLUME.MARCA IS
'Marca.';

COMMENT ON COLUMN TBVENDAS_VOLUME.PESO_BRUTO IS
'Peso Bruto.';

COMMENT ON COLUMN TBVENDAS_VOLUME.PESO_LIQUIDO IS
'Peso Liquido.';




/*------ SYSDBA 06/05/2013 21:33:19 --------*/

ALTER TABLE TBVENDAS_VOLUME
ADD CONSTRAINT FK_TBVENDAS_VOLUME
FOREIGN KEY (ANO_VENDA,CONTROLE_VENDA)
REFERENCES TBVENDAS(ANO,CODCONTROL)
ON DELETE CASCADE
ON UPDATE CASCADE;

GRANT ALL ON TBVENDAS_VOLUME TO "PUBLIC";

/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
PIS.INDICE_ABCR.
At line 2, column 109.

*/

/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
P.INDICE_ABCR.
At line 2, column 103.

*/

/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
P.INDICE_ABCR.
At line 2, column 103.

*/



/*------ SYSDBA 23/05/2013 16:37:50 --------*/

ALTER TABLE TBPRODUTO
    ADD PERCENTUAL_MARCKUP DMN_PERCENTUAL_3;

COMMENT ON COLUMN TBPRODUTO.PERCENTUAL_MARCKUP IS
'Percentual Marckup c/ 3 casas decimais.

Sugestao de composicao:
Percentual Marckup = (Lucro Desejado + Despesas Administrativas e de Venda) / Custo de Entrada';

alter table TBPRODUTO
alter CODIGO position 1;

alter table TBPRODUTO
alter COD position 2;

alter table TBPRODUTO
alter DESCRI position 3;

alter table TBPRODUTO
alter APRESENTACAO position 4;

alter table TBPRODUTO
alter DESCRI_APRESENTACAO position 5;

alter table TBPRODUTO
alter MODELO position 6;

alter table TBPRODUTO
alter PRECO position 7;

alter table TBPRODUTO
alter PRECO_PROMOCAO position 8;

alter table TBPRODUTO
alter REFERENCIA position 9;

alter table TBPRODUTO
alter SECAO position 10;

alter table TBPRODUTO
alter QTDE position 11;

alter table TBPRODUTO
alter UNIDADE position 12;

alter table TBPRODUTO
alter ESTOQMIN position 13;

alter table TBPRODUTO
alter CODGRUPO position 14;

alter table TBPRODUTO
alter CODFABRICANTE position 15;

alter table TBPRODUTO
alter CUSTOMEDIO position 16;

alter table TBPRODUTO
alter PERCENTUAL_MARCKUP position 17;

alter table TBPRODUTO
alter CODEMP position 18;

alter table TBPRODUTO
alter CODSECAO position 19;

alter table TBPRODUTO
alter CODORIGEM position 20;

alter table TBPRODUTO
alter CODTRIBUTACAO position 21;

alter table TBPRODUTO
alter CST position 22;

alter table TBPRODUTO
alter CSOSN position 23;

alter table TBPRODUTO
alter CST_PIS position 24;

alter table TBPRODUTO
alter CST_COFINS position 25;

alter table TBPRODUTO
alter NCM_SH position 26;

alter table TBPRODUTO
alter CODCFOP position 27;

alter table TBPRODUTO
alter CODBARRA_EAN position 28;

alter table TBPRODUTO
alter CODUNIDADE position 29;

alter table TBPRODUTO
alter ALIQUOTA_TIPO position 30;

alter table TBPRODUTO
alter ALIQUOTA position 31;

alter table TBPRODUTO
alter ALIQUOTA_CSOSN position 32;

alter table TBPRODUTO
alter ALIQUOTA_PIS position 33;

alter table TBPRODUTO
alter ALIQUOTA_COFINS position 34;

alter table TBPRODUTO
alter VALOR_IPI position 35;

alter table TBPRODUTO
alter RESERVA position 36;

alter table TBPRODUTO
alter PRODUTO_NOVO position 37;

alter table TBPRODUTO
alter COR_VEICULO position 38;

alter table TBPRODUTO
alter COMBUSTIVEL_VEICULO position 39;

alter table TBPRODUTO
alter TIPO_VEICULO position 40;

alter table TBPRODUTO
alter ANO_MODELO_VEICULO position 41;

alter table TBPRODUTO
alter ANO_FABRICACAO_VEICULO position 42;

alter table TBPRODUTO
alter RENAVAM_VEICULO position 43;

alter table TBPRODUTO
alter CHASSI_VEICULO position 44;

alter table TBPRODUTO
alter KILOMETRAGEM_VEICULO position 45;

alter table TBPRODUTO
alter SITUACAO_ATUAL_VEICULO position 46;

alter table TBPRODUTO
alter SITUACAO_HISTORICO_VEICULO position 47;

alter table TBPRODUTO
alter PERCENTUAL_REDUCAO_BC position 48;




/*------ SYSDBA 23/05/2013 16:41:26 --------*/

ALTER TABLE TBPRODUTO
    ADD PRECO_SUGERIDO DMN_MONEY;

COMMENT ON COLUMN TBPRODUTO.PRECO IS
'Preco Venda.';

COMMENT ON COLUMN TBPRODUTO.PRECO_SUGERIDO IS
'Preco Venda (Sugerido).';

alter table TBPRODUTO
alter CODIGO position 1;

alter table TBPRODUTO
alter COD position 2;

alter table TBPRODUTO
alter DESCRI position 3;

alter table TBPRODUTO
alter APRESENTACAO position 4;

alter table TBPRODUTO
alter DESCRI_APRESENTACAO position 5;

alter table TBPRODUTO
alter MODELO position 6;

alter table TBPRODUTO
alter PRECO position 7;

alter table TBPRODUTO
alter PRECO_PROMOCAO position 8;

alter table TBPRODUTO
alter REFERENCIA position 9;

alter table TBPRODUTO
alter SECAO position 10;

alter table TBPRODUTO
alter QTDE position 11;

alter table TBPRODUTO
alter UNIDADE position 12;

alter table TBPRODUTO
alter ESTOQMIN position 13;

alter table TBPRODUTO
alter CODGRUPO position 14;

alter table TBPRODUTO
alter CODFABRICANTE position 15;

alter table TBPRODUTO
alter CUSTOMEDIO position 16;

alter table TBPRODUTO
alter PERCENTUAL_MARCKUP position 17;

alter table TBPRODUTO
alter PRECO_SUGERIDO position 18;

alter table TBPRODUTO
alter CODEMP position 19;

alter table TBPRODUTO
alter CODSECAO position 20;

alter table TBPRODUTO
alter CODORIGEM position 21;

alter table TBPRODUTO
alter CODTRIBUTACAO position 22;

alter table TBPRODUTO
alter CST position 23;

alter table TBPRODUTO
alter CSOSN position 24;

alter table TBPRODUTO
alter CST_PIS position 25;

alter table TBPRODUTO
alter CST_COFINS position 26;

alter table TBPRODUTO
alter NCM_SH position 27;

alter table TBPRODUTO
alter CODCFOP position 28;

alter table TBPRODUTO
alter CODBARRA_EAN position 29;

alter table TBPRODUTO
alter CODUNIDADE position 30;

alter table TBPRODUTO
alter ALIQUOTA_TIPO position 31;

alter table TBPRODUTO
alter ALIQUOTA position 32;

alter table TBPRODUTO
alter ALIQUOTA_CSOSN position 33;

alter table TBPRODUTO
alter ALIQUOTA_PIS position 34;

alter table TBPRODUTO
alter ALIQUOTA_COFINS position 35;

alter table TBPRODUTO
alter VALOR_IPI position 36;

alter table TBPRODUTO
alter RESERVA position 37;

alter table TBPRODUTO
alter PRODUTO_NOVO position 38;

alter table TBPRODUTO
alter COR_VEICULO position 39;

alter table TBPRODUTO
alter COMBUSTIVEL_VEICULO position 40;

alter table TBPRODUTO
alter TIPO_VEICULO position 41;

alter table TBPRODUTO
alter ANO_MODELO_VEICULO position 42;

alter table TBPRODUTO
alter ANO_FABRICACAO_VEICULO position 43;

alter table TBPRODUTO
alter RENAVAM_VEICULO position 44;

alter table TBPRODUTO
alter CHASSI_VEICULO position 45;

alter table TBPRODUTO
alter KILOMETRAGEM_VEICULO position 46;

alter table TBPRODUTO
alter SITUACAO_ATUAL_VEICULO position 47;

alter table TBPRODUTO
alter SITUACAO_HISTORICO_VEICULO position 48;

alter table TBPRODUTO
alter PERCENTUAL_REDUCAO_BC position 49;


/*------ SYSDBA 23/05/2013 16:54:07 --------*/

Update TBPRODUTO p Set
    p.percentual_marckup = cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) )
  , p.preco_sugerido     = cast( (p.customedio + (p.customedio * ((p.preco - p.customedio) / p.customedio))) as numeric(15,2) )
where (p.percentual_marckup is null)
  and (p.preco_sugerido is null)
  and (coalesce(p.customedio, 0) > 0)
;
/*------ SYSDBA 23/05/2013 16:54:11 --------*/

COMMIT WORK;

/*------ SYSDBA 23/05/2013 16:54:41 --------*/

--update TBVENDAS v set v.nfe_modalidade_frete = 3 where v.nfe_modalidade_frete is null
/*
Select
    p.codigo
  , p.descri
  , p.customedio
  , p.preco
  , p.percentual_marckup
  , p.preco_sugerido
  , cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) ) as tmp_percentual_marckup
  , cast( (p.customedio + (p.customedio * ((p.preco - p.customedio) / p.customedio))) as numeric(15,2) ) as tmp_preco_sugerido
from TBPRODUTO p
--where (p.percentual_marckup is null)
--  and (p.preco_sugerido is null)
*/

Update TBPRODUTO p Set
    p.percentual_marckup = cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) )
  , p.preco_sugerido     = cast( (p.customedio + (p.customedio * ((p.preco - p.customedio) / p.customedio))) as numeric(15,2) )
where (p.percentual_marckup is null)
  and (p.preco_sugerido is null)
  and (coalesce(p.customedio, 0) > 0);
/*------ SYSDBA 23/05/2013 16:54:43 --------*/

COMMIT WORK;

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 65, column 23.
>.

*/



/*------ SYSDBA 03/06/2013 17:52:11 --------*/

ALTER TABLE TBVENDAS
    ADD TOTALCUSTO DMN_MONEY;

COMMENT ON COLUMN TBVENDAS.TOTALCUSTO IS
'Valor Total Custo (Corresponde a totalizacao dos custos dos itens da venda).';

alter table TBVENDAS
alter ANO position 1;

alter table TBVENDAS
alter CODCONTROL position 2;

alter table TBVENDAS
alter CODEMP position 3;

alter table TBVENDAS
alter CODCLI position 4;

alter table TBVENDAS
alter DTVENDA position 5;

alter table TBVENDAS
alter STATUS position 6;

alter table TBVENDAS
alter TOTALVENDA_BRUTA position 7;

alter table TBVENDAS
alter DESCONTO position 8;

alter table TBVENDAS
alter TOTALVENDA position 9;

alter table TBVENDAS
alter TOTALCUSTO position 10;

alter table TBVENDAS
alter DTFINALIZACAO_VENDA position 11;

alter table TBVENDAS
alter OBS position 12;

alter table TBVENDAS
alter FORMAPAG position 13;

alter table TBVENDAS
alter FATDIAS position 14;

alter table TBVENDAS
alter SERIE position 15;

alter table TBVENDAS
alter NFE position 16;

alter table TBVENDAS
alter DATAEMISSAO position 17;

alter table TBVENDAS
alter HORAEMISSAO position 18;

alter table TBVENDAS
alter CFOP position 19;

alter table TBVENDAS
alter VERIFICADOR_NFE position 20;

alter table TBVENDAS
alter XML_NFE position 21;

alter table TBVENDAS
alter VENDEDOR_COD position 22;

alter table TBVENDAS
alter USUARIO position 23;

alter table TBVENDAS
alter FORMAPAGTO_COD position 24;

alter table TBVENDAS
alter CONDICAOPAGTO_COD position 25;

alter table TBVENDAS
alter VENDA_PRAZO position 26;

alter table TBVENDAS
alter PRAZO_01 position 27;

alter table TBVENDAS
alter PRAZO_02 position 28;

alter table TBVENDAS
alter PRAZO_03 position 29;

alter table TBVENDAS
alter PRAZO_04 position 30;

alter table TBVENDAS
alter PRAZO_05 position 31;

alter table TBVENDAS
alter PRAZO_06 position 32;

alter table TBVENDAS
alter PRAZO_07 position 33;

alter table TBVENDAS
alter PRAZO_08 position 34;

alter table TBVENDAS
alter PRAZO_09 position 35;

alter table TBVENDAS
alter PRAZO_10 position 36;

alter table TBVENDAS
alter PRAZO_11 position 37;

alter table TBVENDAS
alter PRAZO_12 position 38;

alter table TBVENDAS
alter LOTE_NFE_ANO position 39;

alter table TBVENDAS
alter LOTE_NFE_NUMERO position 40;

alter table TBVENDAS
alter NFE_ENVIADA position 41;

alter table TBVENDAS
alter CANCEL_USUARIO position 42;

alter table TBVENDAS
alter CANCEL_DATAHORA position 43;

alter table TBVENDAS
alter CANCEL_MOTIVO position 44;

alter table TBVENDAS
alter XML_NFE_FILENAME position 45;

alter table TBVENDAS
alter NFE_MODALIDADE_FRETE position 46;

alter table TBVENDAS
alter NFE_TRANSPORTADORA position 47;

alter table TBVENDAS
alter NFE_PLACA_VEICULO position 48;

alter table TBVENDAS
alter NFE_PLACA_UF position 49;

alter table TBVENDAS
alter NFE_PLACA_RNTC position 50;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS position 51;

alter table TBVENDAS
alter NFE_VALOR_ICMS position 52;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS_SUBST position 53;

alter table TBVENDAS
alter NFE_VALOR_ICMS_SUBST position 54;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_PRODUTO position 55;

alter table TBVENDAS
alter NFE_VALOR_FRETE position 56;

alter table TBVENDAS
alter NFE_VALOR_SEGURO position 57;

alter table TBVENDAS
alter NFE_VALOR_DESCONTO position 58;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_II position 59;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_IPI position 60;

alter table TBVENDAS
alter NFE_VALOR_PIS position 61;

alter table TBVENDAS
alter NFE_VALOR_COFINS position 62;

alter table TBVENDAS
alter NFE_VALOR_OUTROS position 63;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_NOTA position 64;




/*------ SYSDBA 03/06/2013 17:52:33 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY'
where (RDB$FIELD_NAME = 'TOTALVENDA') and
(RDB$RELATION_NAME = 'TBVENDAS')
;




/*------ SYSDBA 03/06/2013 17:55:22 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendasitens_total_venda for tvendasitens
active after insert or update or delete position 10
AS
  declare variable anovenda Smallint;
  declare variable numvenda Integer;
  declare variable total_bruto Dmn_money;
  declare variable total_desconto dmn_money;
  declare variable total_liquido Dmn_money;
  declare variable total_custo Dmn_money;
begin
  if ( (Inserting) or (Updating) ) then
  begin
    anovenda = new.Ano;
    numvenda = new.Codcontrol;
  end
  else
  begin
    anovenda = old.Ano;
    numvenda = old.Codcontrol;
  end

  Select
      sum( coalesce(i.total_bruto,    0) )
    , sum( coalesce(i.total_desconto, 0) )
    , sum( coalesce(i.qtde, 0) * coalesce(p.customedio, 0) )
  from TVENDASITENS i
    inner join TBPRODUTO p on (p.cod = i.codprod)
  where i.Ano = :Anovenda
    and i.Codcontrol = :Numvenda
  into
      Total_bruto
    , Total_desconto
    , Total_custo;

  Total_bruto    = coalesce(:Total_bruto, 0);
  Total_desconto = coalesce(:Total_desconto, 0);
  total_liquido  = :Total_bruto - :Total_desconto;

  Update TBVENDAS v Set
      v.Totalvenda_bruta = :Total_bruto
    , v.Desconto   = :Total_desconto
    , v.Totalvenda = :Total_liquido
    , v.Totalcusto = :Total_custo
  where v.Ano = :Anovenda
    and v.Codcontrol = :Numvenda;
end^

SET TERM ; ^


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 59, column 29.
when.

*/



/*------ SYSDBA 04/06/2013 13:50:51 --------*/

CREATE SEQUENCE IBE$LOG_TABLES_GEN;

CREATE TABLE IBE$LOG_TABLES (
  ID NUMERIC(18,0) NOT NULL PRIMARY KEY,
  TABLE_NAME VARCHAR(67) CHARACTER SET UTF8 NOT NULL,
  OPERATION VARCHAR(1) NOT NULL,
  DATE_TIME TIMESTAMP NOT NULL,
  USER_NAME VARCHAR(67) NOT NULL);

CREATE TABLE IBE$LOG_KEYS (
  LOG_TABLES_ID NUMERIC(18,0) NOT NULL,
  KEY_FIELD VARCHAR(67) CHARACTER SET UTF8 NOT NULL,
  KEY_VALUE VARCHAR(255) CHARACTER SET UTF8);

CREATE INDEX IBE$LOG_KEYS_IDX1
ON IBE$LOG_KEYS (LOG_TABLES_ID);

CREATE TABLE IBE$LOG_FIELDS (
  LOG_TABLES_ID NUMERIC(18,0) NOT NULL,
  FIELD_NAME VARCHAR(67) CHARACTER SET UTF8 NOT NULL,
  OLD_VALUE VARCHAR(255) CHARACTER SET UTF8,
  NEW_VALUE VARCHAR(255) CHARACTER SET UTF8);

CREATE INDEX IBE$LOG_FIELDS_IDX1
ON IBE$LOG_FIELDS (LOG_TABLES_ID);

CREATE TABLE IBE$LOG_BLOB_FIELDS (
  LOG_TABLES_ID NUMERIC(18,0) NOT NULL,
  FIELD_NAME VARCHAR(67) CHARACTER SET UTF8 NOT NULL,
  OLD_CHAR_VALUE VARCHAR(8000) CHARACTER SET UTF8,
  NEW_CHAR_VALUE VARCHAR(8000) CHARACTER SET UTF8,
  OLD_BLOB_VALUE BLOB,
  NEW_BLOB_VALUE BLOB);

CREATE INDEX IBE$LOG_BLOB_FIELDS_IDX1
ON IBE$LOG_BLOB_FIELDS (LOG_TABLES_ID);

SET TERM ^ ;

CREATE TRIGGER IBE$LOG_TABLES_BD FOR IBE$LOG_TABLES
ACTIVE BEFORE DELETE POSITION 0
AS
BEGIN
  DELETE FROM IBE$LOG_FIELDS WHERE LOG_TABLES_ID = OLD.ID;
  DELETE FROM IBE$LOG_BLOB_FIELDS WHERE LOG_TABLES_ID = OLD.ID;
  DELETE FROM IBE$LOG_KEYS WHERE LOG_TABLES_ID = OLD.ID;
END^

SET TERM ; ^

GRANT UPDATE,REFERENCES ON IBE$LOG_TABLES TO TRIGGER IBE$LOG_TABLES_BD;

GRANT SELECT,DELETE ON IBE$LOG_FIELDS TO TRIGGER IBE$LOG_TABLES_BD;

GRANT SELECT,DELETE ON IBE$LOG_BLOB_FIELDS TO TRIGGER IBE$LOG_TABLES_BD;

GRANT SELECT,DELETE ON IBE$LOG_KEYS TO TRIGGER IBE$LOG_TABLES_BD;




/*------ SYSDBA 04/06/2013 13:54:40 --------*/

COMMENT ON COLUMN TBCLIENTE.CODIGO IS
'Codigo';




/*------ SYSDBA 04/06/2013 13:54:57 --------*/

COMMENT ON COLUMN TBCLIENTE.PESSOA_FISICA IS
'Pessoa Fisica:
0 - Nao
1 - Sim';




/*------ SYSDBA 04/06/2013 13:55:03 --------*/

COMMENT ON COLUMN TBCLIENTE.CNPJ IS
'CPF/CNPJ';




/*------ SYSDBA 04/06/2013 13:55:07 --------*/

COMMENT ON COLUMN TBCLIENTE.NOME IS
'Nome';




/*------ SYSDBA 04/06/2013 13:55:21 --------*/

COMMENT ON COLUMN TBCLIENTE.INSCEST IS
'RG / Inscricao Estadual';




/*------ SYSDBA 04/06/2013 13:55:29 --------*/

COMMENT ON COLUMN TBCLIENTE.INSCMUN IS
'Inscricao Municipal';




/*------ SYSDBA 04/06/2013 13:55:35 --------*/

COMMENT ON COLUMN TBCLIENTE.ENDER IS
'Endereco';




/*------ SYSDBA 04/06/2013 13:55:52 --------*/

COMMENT ON COLUMN TBCLIENTE.COMPLEMENTO IS
'Complemento';




/*------ SYSDBA 04/06/2013 13:56:09 --------*/

COMMENT ON COLUMN TBCLIENTE.BAIRRO IS
'Bairro';




/*------ SYSDBA 04/06/2013 13:56:12 --------*/

COMMENT ON COLUMN TBCLIENTE.CEP IS
'CEP';




/*------ SYSDBA 04/06/2013 13:56:17 --------*/

COMMENT ON COLUMN TBCLIENTE.CIDADE IS
'Cidade';




/*------ SYSDBA 04/06/2013 13:56:20 --------*/

COMMENT ON COLUMN TBCLIENTE.UF IS
'UF';




/*------ SYSDBA 04/06/2013 13:56:30 --------*/

COMMENT ON COLUMN TBCLIENTE.FONE IS
'Telefone Fixo';




/*------ SYSDBA 04/06/2013 13:56:32 --------*/

COMMENT ON COLUMN TBCLIENTE.FONECEL IS
'Telefone Celular';




/*------ SYSDBA 04/06/2013 13:56:35 --------*/

COMMENT ON COLUMN TBCLIENTE.FONECOMERC IS
'Telefone Comercial';




/*------ SYSDBA 04/06/2013 13:56:40 --------*/

COMMENT ON COLUMN TBCLIENTE.EMAIL IS
'E-mail';




/*------ SYSDBA 04/06/2013 13:56:46 --------*/

COMMENT ON COLUMN TBCLIENTE.SITE IS
'Home Page';




/*------ SYSDBA 04/06/2013 13:56:56 --------*/

COMMENT ON COLUMN TBCLIENTE.TLG_TIPO IS
'Tipo Logradouro';




/*------ SYSDBA 04/06/2013 13:57:12 --------*/

COMMENT ON COLUMN TBCLIENTE.LOG_COD IS
'Logradouro';




/*------ SYSDBA 04/06/2013 13:57:18 --------*/

COMMENT ON COLUMN TBCLIENTE.BAI_COD IS
'Bairro';




/*------ SYSDBA 04/06/2013 13:57:22 --------*/

COMMENT ON COLUMN TBCLIENTE.CID_COD IS
'Cidade';




/*------ SYSDBA 04/06/2013 13:57:26 --------*/

COMMENT ON COLUMN TBCLIENTE.EST_COD IS
'Estado';




/*------ SYSDBA 04/06/2013 13:57:33 --------*/

COMMENT ON COLUMN TBCLIENTE.NUMERO_END IS
'Numero Endereco';




/*------ SYSDBA 04/06/2013 13:57:37 --------*/

COMMENT ON COLUMN TBCLIENTE.PAIS_ID IS
'Pais';




/*------ SYSDBA 04/06/2013 13:57:49 --------*/

COMMENT ON COLUMN TBCLIENTE.VALOR_LIMITE_COMPRA IS
'Valor Limite de Credito';




/*------ SYSDBA 04/06/2013 13:57:55 --------*/

COMMENT ON COLUMN TBCLIENTE.BLOQUEADO IS
'Bloqueado:
0 - Nao
1 - Sim';




/*------ SYSDBA 04/06/2013 13:57:58 --------*/

COMMENT ON COLUMN TBCLIENTE.BLOQUEADO_DATA IS
'Data do bloqueio';




/*------ SYSDBA 04/06/2013 13:58:00 --------*/

COMMENT ON COLUMN TBCLIENTE.BLOQUEADO_MOTIVO IS
'Motivo do bloqueio';




/*------ SYSDBA 04/06/2013 13:58:05 --------*/

COMMENT ON COLUMN TBCLIENTE.BLOQUEADO_USUARIO IS
'Usuario do bloqueio';




/*------ SYSDBA 04/06/2013 13:58:08 --------*/

COMMENT ON COLUMN TBCLIENTE.DESBLOQUEADO_DATA IS
'Data de desbloqueio';




/*------ SYSDBA 04/06/2013 13:58:24 --------*/

COMMENT ON COLUMN TBCLIENTE.DTCAD IS
'Data Cadastro';




/*------ SYSDBA 04/06/2013 13:58:28 --------*/

COMMENT ON COLUMN TBCLIENTE.VENDEDOR_COD IS
'Vendedor responsavel pelo cliente';

GRANT ALL ON IBE$LOG_BLOB_FIELDS TO "PUBLIC";
GRANT ALL ON IBE$LOG_FIELDS TO "PUBLIC";
GRANT ALL ON IBE$LOG_KEYS TO "PUBLIC";
GRANT ALL ON IBE$LOG_TABLES TO "PUBLIC";
GRANT EXECUTE ON PROCEDURE SET_CAIXA_MOVIMENTO_PAG_ESTORNO TO "PUBLIC";
GRANT EXECUTE ON PROCEDURE SET_CAIXA_MOVIMENTO_REC_ESTORNO TO "PUBLIC";



/*------ SYSDBA 04/06/2013 14:07:47 --------*/

SET TERM ^ ;

CREATE TRIGGER IBE$TBCLIENTE_AI FOR TBCLIENTE
ACTIVE AFTER INSERT POSITION 32767
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'I', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', new.cnpj);

  if (new.codigo is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CODIGO', null, new.codigo);

  if (new.pessoa_fisica is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PESSOA_FISICA', null, new.pessoa_fisica);

  if (new.cnpj is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CNPJ', null, new.cnpj);

  if (new.nome is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NOME', null, new.nome);

  if (new.inscest is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCEST', null, new.inscest);

  if (new.inscmun is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCMUN', null, new.inscmun);

  if (new.ender is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'ENDER', null, new.ender);

  if (new.complemento is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'COMPLEMENTO', null, new.complemento);

  if (new.bairro is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BAIRRO', null, new.bairro);

  if (new.cep is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CEP', null, new.cep);

  if (new.cidade is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CIDADE', null, new.cidade);

  if (new.uf is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'UF', null, new.uf);

  if (new.fone is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONE', null, new.fone);

  if (new.fonecel is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECEL', null, new.fonecel);

  if (new.fonecomerc is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECOMERC', null, new.fonecomerc);

  if (new.email is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'EMAIL', null, new.email);

  if (new.site is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'SITE', null, new.site);

  if (new.numero_end is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NUMERO_END', null, new.numero_end);

  if (new.pais_id is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PAIS_ID', null, new.pais_id);

  if (new.valor_limite_compra is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VALOR_LIMITE_COMPRA', null, new.valor_limite_compra);

  if (new.bloqueado is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO', null, new.bloqueado);

  if (new.bloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_DATA', null, new.bloqueado_data);

  if (not (new.bloqueado_motivo is null)) then
    insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
           values (:tid,'BLOQUEADO_MOTIVO',null, new.bloqueado_motivo);

  if (new.bloqueado_usuario is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_USUARIO', null, new.bloqueado_usuario);

  if (new.desbloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DESBLOQUEADO_DATA', null, new.desbloqueado_data);

  if (new.dtcad is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DTCAD', null, new.dtcad);

  if (new.vendedor_cod is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VENDEDOR_COD', null, new.vendedor_cod);


end;^

SET TERM ; ^

SET TERM ^ ;

CREATE TRIGGER IBE$TBCLIENTE_AU FOR TBCLIENTE
ACTIVE AFTER UPDATE POSITION 32767
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'U', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  if ((old.pessoa_fisica is null and new.pessoa_fisica is not null) or
      (new.pessoa_fisica is null and old.pessoa_fisica is not null) or
      (new.pessoa_fisica is not null and old.pessoa_fisica is not null and new.pessoa_fisica <> old.pessoa_fisica)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, new.pessoa_fisica);

  if ((old.cnpj is null and new.cnpj is not null) or
      (new.cnpj is null and old.cnpj is not null) or
      (new.cnpj is not null and old.cnpj is not null and new.cnpj <> old.cnpj)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CNPJ', old.cnpj, new.cnpj);

  if ((old.nome is null and new.nome is not null) or
      (new.nome is null and old.nome is not null) or
      (new.nome is not null and old.nome is not null and new.nome <> old.nome)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NOME', old.nome, new.nome);

  if ((old.inscest is null and new.inscest is not null) or
      (new.inscest is null and old.inscest is not null) or
      (new.inscest is not null and old.inscest is not null and new.inscest <> old.inscest)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCEST', old.inscest, new.inscest);

  if ((old.inscmun is null and new.inscmun is not null) or
      (new.inscmun is null and old.inscmun is not null) or
      (new.inscmun is not null and old.inscmun is not null and new.inscmun <> old.inscmun)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCMUN', old.inscmun, new.inscmun);

  if ((old.ender is null and new.ender is not null) or
      (new.ender is null and old.ender is not null) or
      (new.ender is not null and old.ender is not null and new.ender <> old.ender)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'ENDER', old.ender, new.ender);

  if ((old.complemento is null and new.complemento is not null) or
      (new.complemento is null and old.complemento is not null) or
      (new.complemento is not null and old.complemento is not null and new.complemento <> old.complemento)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'COMPLEMENTO', old.complemento, new.complemento);

  if ((old.bairro is null and new.bairro is not null) or
      (new.bairro is null and old.bairro is not null) or
      (new.bairro is not null and old.bairro is not null and new.bairro <> old.bairro)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BAIRRO', old.bairro, new.bairro);

  if ((old.cep is null and new.cep is not null) or
      (new.cep is null and old.cep is not null) or
      (new.cep is not null and old.cep is not null and new.cep <> old.cep)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CEP', old.cep, new.cep);

  if ((old.cidade is null and new.cidade is not null) or
      (new.cidade is null and old.cidade is not null) or
      (new.cidade is not null and old.cidade is not null and new.cidade <> old.cidade)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CIDADE', old.cidade, new.cidade);

  if ((old.uf is null and new.uf is not null) or
      (new.uf is null and old.uf is not null) or
      (new.uf is not null and old.uf is not null and new.uf <> old.uf)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'UF', old.uf, new.uf);

  if ((old.fone is null and new.fone is not null) or
      (new.fone is null and old.fone is not null) or
      (new.fone is not null and old.fone is not null and new.fone <> old.fone)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONE', old.fone, new.fone);

  if ((old.fonecel is null and new.fonecel is not null) or
      (new.fonecel is null and old.fonecel is not null) or
      (new.fonecel is not null and old.fonecel is not null and new.fonecel <> old.fonecel)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECEL', old.fonecel, new.fonecel);

  if ((old.fonecomerc is null and new.fonecomerc is not null) or
      (new.fonecomerc is null and old.fonecomerc is not null) or
      (new.fonecomerc is not null and old.fonecomerc is not null and new.fonecomerc <> old.fonecomerc)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECOMERC', old.fonecomerc, new.fonecomerc);

  if ((old.email is null and new.email is not null) or
      (new.email is null and old.email is not null) or
      (new.email is not null and old.email is not null and new.email <> old.email)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'EMAIL', old.email, new.email);

  if ((old.site is null and new.site is not null) or
      (new.site is null and old.site is not null) or
      (new.site is not null and old.site is not null and new.site <> old.site)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'SITE', old.site, new.site);

  if ((old.numero_end is null and new.numero_end is not null) or
      (new.numero_end is null and old.numero_end is not null) or
      (new.numero_end is not null and old.numero_end is not null and new.numero_end <> old.numero_end)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NUMERO_END', old.numero_end, new.numero_end);

  if ((old.pais_id is null and new.pais_id is not null) or
      (new.pais_id is null and old.pais_id is not null) or
      (new.pais_id is not null and old.pais_id is not null and new.pais_id <> old.pais_id)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PAIS_ID', old.pais_id, new.pais_id);

  if ((old.valor_limite_compra is null and new.valor_limite_compra is not null) or
      (new.valor_limite_compra is null and old.valor_limite_compra is not null) or
      (new.valor_limite_compra is not null and old.valor_limite_compra is not null and new.valor_limite_compra <> old.valor_limite_compra)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, new.valor_limite_compra);

  if ((old.bloqueado is null and new.bloqueado is not null) or
      (new.bloqueado is null and old.bloqueado is not null) or
      (new.bloqueado is not null and old.bloqueado is not null and new.bloqueado <> old.bloqueado)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO', old.bloqueado, new.bloqueado);

  if ((old.bloqueado_data is null and new.bloqueado_data is not null) or
      (new.bloqueado_data is null and old.bloqueado_data is not null) or
      (new.bloqueado_data is not null and old.bloqueado_data is not null and new.bloqueado_data <> old.bloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, new.bloqueado_data);

  if ((old.bloqueado_motivo is null and new.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is null and old.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is not null and old.bloqueado_motivo is not null and new.bloqueado_motivo <> old.bloqueado_motivo)) then
     insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
            values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, new.bloqueado_motivo);

  if ((old.bloqueado_usuario is null and new.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is null and old.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is not null and old.bloqueado_usuario is not null and new.bloqueado_usuario <> old.bloqueado_usuario)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, new.bloqueado_usuario);

  if ((old.desbloqueado_data is null and new.desbloqueado_data is not null) or
      (new.desbloqueado_data is null and old.desbloqueado_data is not null) or
      (new.desbloqueado_data is not null and old.desbloqueado_data is not null and new.desbloqueado_data <> old.desbloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, new.desbloqueado_data);

  if ((old.dtcad is null and new.dtcad is not null) or
      (new.dtcad is null and old.dtcad is not null) or
      (new.dtcad is not null and old.dtcad is not null and new.dtcad <> old.dtcad)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DTCAD', old.dtcad, new.dtcad);

  if ((old.vendedor_cod is null and new.vendedor_cod is not null) or
      (new.vendedor_cod is null and old.vendedor_cod is not null) or
      (new.vendedor_cod is not null and old.vendedor_cod is not null and new.vendedor_cod <> old.vendedor_cod)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VENDEDOR_COD', old.vendedor_cod, new.vendedor_cod);


end;^

SET TERM ; ^

SET TERM ^ ;

CREATE TRIGGER IBE$TBCLIENTE_AD FOR TBCLIENTE
ACTIVE AFTER DELETE POSITION 32767
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'D', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CODIGO', old.codigo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CNPJ', old.cnpj, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NOME', old.nome, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCEST', old.inscest, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCMUN', old.inscmun, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'ENDER', old.ender, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'COMPLEMENTO', old.complemento, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BAIRRO', old.bairro, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CEP', old.cep, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CIDADE', old.cidade, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'UF', old.uf, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONE', old.fone, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECEL', old.fonecel, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECOMERC', old.fonecomerc, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'EMAIL', old.email, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'SITE', old.site, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NUMERO_END', old.numero_end, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PAIS_ID', old.pais_id, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO', old.bloqueado, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, null);

  insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
         values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DTCAD', old.dtcad, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VENDEDOR_COD', old.vendedor_cod, null);


end;^

SET TERM ; ^




/*------ SYSDBA 04/06/2013 14:10:57 --------*/

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AI
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'I', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', new.cnpj);

  if (new.codigo is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CODIGO', null, new.codigo);

  if (new.pessoa_fisica is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PESSOA_FISICA', null, new.pessoa_fisica);

  if (new.cnpj is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CNPJ', null, new.cnpj);

  if (new.nome is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NOME', null, new.nome);

  if (new.inscest is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCEST', null, new.inscest);

  if (new.inscmun is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCMUN', null, new.inscmun);

  if (new.ender is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'ENDER', null, new.ender);

  if (new.complemento is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'COMPLEMENTO', null, new.complemento);

  if (new.bairro is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BAIRRO', null, new.bairro);

  if (new.cep is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CEP', null, new.cep);

  if (new.cidade is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CIDADE', null, new.cidade);

  if (new.uf is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'UF', null, new.uf);

  if (new.fone is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONE', null, new.fone);

  if (new.fonecel is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECEL', null, new.fonecel);

  if (new.fonecomerc is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECOMERC', null, new.fonecomerc);

  if (new.email is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'EMAIL', null, new.email);

  if (new.site is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'SITE', null, new.site);

  if (new.numero_end is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NUMERO_END', null, new.numero_end);

  if (new.pais_id is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PAIS_ID', null, new.pais_id);

  if (new.valor_limite_compra is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VALOR_LIMITE_COMPRA', null, new.valor_limite_compra);

  if (new.bloqueado is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO', null, new.bloqueado);

  if (new.bloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_DATA', null, new.bloqueado_data);

  if (not (new.bloqueado_motivo is null)) then
    insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
           values (:tid,'BLOQUEADO_MOTIVO',null, new.bloqueado_motivo);

  if (new.bloqueado_usuario is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_USUARIO', null, new.bloqueado_usuario);

  if (new.desbloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DESBLOQUEADO_DATA', null, new.desbloqueado_data);

  if (new.dtcad is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DTCAD', null, new.dtcad);

  if (new.vendedor_cod is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VENDEDOR_COD', null, new.vendedor_cod);


end;^

SET TERM ; ^

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AU
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'U', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  if ((old.codigo is null and new.codigo is not null) or
      (new.codigo is null and old.codigo is not null) or
      (new.codigo is not null and old.codigo is not null and new.codigo <> old.codigo)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CODIGO', old.codigo, new.codigo);

  if ((old.pessoa_fisica is null and new.pessoa_fisica is not null) or
      (new.pessoa_fisica is null and old.pessoa_fisica is not null) or
      (new.pessoa_fisica is not null and old.pessoa_fisica is not null and new.pessoa_fisica <> old.pessoa_fisica)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, new.pessoa_fisica);

  if ((old.nome is null and new.nome is not null) or
      (new.nome is null and old.nome is not null) or
      (new.nome is not null and old.nome is not null and new.nome <> old.nome)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NOME', old.nome, new.nome);

  if ((old.inscest is null and new.inscest is not null) or
      (new.inscest is null and old.inscest is not null) or
      (new.inscest is not null and old.inscest is not null and new.inscest <> old.inscest)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCEST', old.inscest, new.inscest);

  if ((old.inscmun is null and new.inscmun is not null) or
      (new.inscmun is null and old.inscmun is not null) or
      (new.inscmun is not null and old.inscmun is not null and new.inscmun <> old.inscmun)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCMUN', old.inscmun, new.inscmun);

  if ((old.ender is null and new.ender is not null) or
      (new.ender is null and old.ender is not null) or
      (new.ender is not null and old.ender is not null and new.ender <> old.ender)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'ENDER', old.ender, new.ender);

  if ((old.complemento is null and new.complemento is not null) or
      (new.complemento is null and old.complemento is not null) or
      (new.complemento is not null and old.complemento is not null and new.complemento <> old.complemento)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'COMPLEMENTO', old.complemento, new.complemento);

  if ((old.bairro is null and new.bairro is not null) or
      (new.bairro is null and old.bairro is not null) or
      (new.bairro is not null and old.bairro is not null and new.bairro <> old.bairro)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BAIRRO', old.bairro, new.bairro);

  if ((old.cep is null and new.cep is not null) or
      (new.cep is null and old.cep is not null) or
      (new.cep is not null and old.cep is not null and new.cep <> old.cep)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CEP', old.cep, new.cep);

  if ((old.cidade is null and new.cidade is not null) or
      (new.cidade is null and old.cidade is not null) or
      (new.cidade is not null and old.cidade is not null and new.cidade <> old.cidade)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CIDADE', old.cidade, new.cidade);

  if ((old.uf is null and new.uf is not null) or
      (new.uf is null and old.uf is not null) or
      (new.uf is not null and old.uf is not null and new.uf <> old.uf)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'UF', old.uf, new.uf);

  if ((old.fone is null and new.fone is not null) or
      (new.fone is null and old.fone is not null) or
      (new.fone is not null and old.fone is not null and new.fone <> old.fone)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONE', old.fone, new.fone);

  if ((old.fonecel is null and new.fonecel is not null) or
      (new.fonecel is null and old.fonecel is not null) or
      (new.fonecel is not null and old.fonecel is not null and new.fonecel <> old.fonecel)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECEL', old.fonecel, new.fonecel);

  if ((old.fonecomerc is null and new.fonecomerc is not null) or
      (new.fonecomerc is null and old.fonecomerc is not null) or
      (new.fonecomerc is not null and old.fonecomerc is not null and new.fonecomerc <> old.fonecomerc)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECOMERC', old.fonecomerc, new.fonecomerc);

  if ((old.email is null and new.email is not null) or
      (new.email is null and old.email is not null) or
      (new.email is not null and old.email is not null and new.email <> old.email)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'EMAIL', old.email, new.email);

  if ((old.site is null and new.site is not null) or
      (new.site is null and old.site is not null) or
      (new.site is not null and old.site is not null and new.site <> old.site)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'SITE', old.site, new.site);

  if ((old.numero_end is null and new.numero_end is not null) or
      (new.numero_end is null and old.numero_end is not null) or
      (new.numero_end is not null and old.numero_end is not null and new.numero_end <> old.numero_end)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NUMERO_END', old.numero_end, new.numero_end);

  if ((old.pais_id is null and new.pais_id is not null) or
      (new.pais_id is null and old.pais_id is not null) or
      (new.pais_id is not null and old.pais_id is not null and new.pais_id <> old.pais_id)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PAIS_ID', old.pais_id, new.pais_id);

  if ((old.valor_limite_compra is null and new.valor_limite_compra is not null) or
      (new.valor_limite_compra is null and old.valor_limite_compra is not null) or
      (new.valor_limite_compra is not null and old.valor_limite_compra is not null and new.valor_limite_compra <> old.valor_limite_compra)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, new.valor_limite_compra);

  if ((old.bloqueado is null and new.bloqueado is not null) or
      (new.bloqueado is null and old.bloqueado is not null) or
      (new.bloqueado is not null and old.bloqueado is not null and new.bloqueado <> old.bloqueado)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO', old.bloqueado, new.bloqueado);

  if ((old.bloqueado_data is null and new.bloqueado_data is not null) or
      (new.bloqueado_data is null and old.bloqueado_data is not null) or
      (new.bloqueado_data is not null and old.bloqueado_data is not null and new.bloqueado_data <> old.bloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, new.bloqueado_data);

  if ((old.bloqueado_motivo is null and new.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is null and old.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is not null and old.bloqueado_motivo is not null and new.bloqueado_motivo <> old.bloqueado_motivo)) then
     insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
            values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, new.bloqueado_motivo);

  if ((old.bloqueado_usuario is null and new.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is null and old.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is not null and old.bloqueado_usuario is not null and new.bloqueado_usuario <> old.bloqueado_usuario)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, new.bloqueado_usuario);

  if ((old.desbloqueado_data is null and new.desbloqueado_data is not null) or
      (new.desbloqueado_data is null and old.desbloqueado_data is not null) or
      (new.desbloqueado_data is not null and old.desbloqueado_data is not null and new.desbloqueado_data <> old.desbloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, new.desbloqueado_data);

  if ((old.dtcad is null and new.dtcad is not null) or
      (new.dtcad is null and old.dtcad is not null) or
      (new.dtcad is not null and old.dtcad is not null and new.dtcad <> old.dtcad)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DTCAD', old.dtcad, new.dtcad);

  if ((old.vendedor_cod is null and new.vendedor_cod is not null) or
      (new.vendedor_cod is null and old.vendedor_cod is not null) or
      (new.vendedor_cod is not null and old.vendedor_cod is not null and new.vendedor_cod <> old.vendedor_cod)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VENDEDOR_COD', old.vendedor_cod, new.vendedor_cod);


end;^

SET TERM ; ^

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AD
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'D', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CODIGO', old.codigo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CNPJ', old.cnpj, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NOME', old.nome, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCEST', old.inscest, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCMUN', old.inscmun, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'ENDER', old.ender, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'COMPLEMENTO', old.complemento, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BAIRRO', old.bairro, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CEP', old.cep, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CIDADE', old.cidade, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'UF', old.uf, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONE', old.fone, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECEL', old.fonecel, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECOMERC', old.fonecomerc, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'EMAIL', old.email, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'SITE', old.site, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NUMERO_END', old.numero_end, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PAIS_ID', old.pais_id, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO', old.bloqueado, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, null);

  insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
         values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DTCAD', old.dtcad, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VENDEDOR_COD', old.vendedor_cod, null);


end;^

SET TERM ; ^




/*------ SYSDBA 04/06/2013 14:14:24 --------*/

ALTER TABLE TBCLIENTE
    ADD USUARIO DMN_VCHAR_50;

COMMENT ON COLUMN TBCLIENTE.USUARIO IS
'Usuario Insercao/Atualizacao';




/*------ SYSDBA 04/06/2013 14:14:37 --------*/

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AI
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'I', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', new.cnpj);

  if (new.codigo is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CODIGO', null, new.codigo);

  if (new.pessoa_fisica is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PESSOA_FISICA', null, new.pessoa_fisica);

  if (new.cnpj is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CNPJ', null, new.cnpj);

  if (new.nome is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NOME', null, new.nome);

  if (new.inscest is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCEST', null, new.inscest);

  if (new.inscmun is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'INSCMUN', null, new.inscmun);

  if (new.ender is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'ENDER', null, new.ender);

  if (new.complemento is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'COMPLEMENTO', null, new.complemento);

  if (new.bairro is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BAIRRO', null, new.bairro);

  if (new.cep is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CEP', null, new.cep);

  if (new.cidade is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'CIDADE', null, new.cidade);

  if (new.uf is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'UF', null, new.uf);

  if (new.fone is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONE', null, new.fone);

  if (new.fonecel is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECEL', null, new.fonecel);

  if (new.fonecomerc is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'FONECOMERC', null, new.fonecomerc);

  if (new.email is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'EMAIL', null, new.email);

  if (new.site is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'SITE', null, new.site);

  if (new.numero_end is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'NUMERO_END', null, new.numero_end);

  if (new.pais_id is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'PAIS_ID', null, new.pais_id);

  if (new.valor_limite_compra is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VALOR_LIMITE_COMPRA', null, new.valor_limite_compra);

  if (new.bloqueado is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO', null, new.bloqueado);

  if (new.bloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_DATA', null, new.bloqueado_data);

  if (not (new.bloqueado_motivo is null)) then
    insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
           values (:tid,'BLOQUEADO_MOTIVO',null, new.bloqueado_motivo);

  if (new.bloqueado_usuario is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'BLOQUEADO_USUARIO', null, new.bloqueado_usuario);

  if (new.desbloqueado_data is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DESBLOQUEADO_DATA', null, new.desbloqueado_data);

  if (new.dtcad is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'DTCAD', null, new.dtcad);

  if (new.vendedor_cod is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'VENDEDOR_COD', null, new.vendedor_cod);

  if (new.usuario is not null) then
    insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
           values (:tid, 'USUARIO', null, new.usuario);


end;^

SET TERM ; ^

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AU
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'U', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  if ((old.codigo is null and new.codigo is not null) or
      (new.codigo is null and old.codigo is not null) or
      (new.codigo is not null and old.codigo is not null and new.codigo <> old.codigo)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CODIGO', old.codigo, new.codigo);

  if ((old.pessoa_fisica is null and new.pessoa_fisica is not null) or
      (new.pessoa_fisica is null and old.pessoa_fisica is not null) or
      (new.pessoa_fisica is not null and old.pessoa_fisica is not null and new.pessoa_fisica <> old.pessoa_fisica)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, new.pessoa_fisica);

  if ((old.nome is null and new.nome is not null) or
      (new.nome is null and old.nome is not null) or
      (new.nome is not null and old.nome is not null and new.nome <> old.nome)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NOME', old.nome, new.nome);

  if ((old.inscest is null and new.inscest is not null) or
      (new.inscest is null and old.inscest is not null) or
      (new.inscest is not null and old.inscest is not null and new.inscest <> old.inscest)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCEST', old.inscest, new.inscest);

  if ((old.inscmun is null and new.inscmun is not null) or
      (new.inscmun is null and old.inscmun is not null) or
      (new.inscmun is not null and old.inscmun is not null and new.inscmun <> old.inscmun)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'INSCMUN', old.inscmun, new.inscmun);

  if ((old.ender is null and new.ender is not null) or
      (new.ender is null and old.ender is not null) or
      (new.ender is not null and old.ender is not null and new.ender <> old.ender)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'ENDER', old.ender, new.ender);

  if ((old.complemento is null and new.complemento is not null) or
      (new.complemento is null and old.complemento is not null) or
      (new.complemento is not null and old.complemento is not null and new.complemento <> old.complemento)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'COMPLEMENTO', old.complemento, new.complemento);

  if ((old.bairro is null and new.bairro is not null) or
      (new.bairro is null and old.bairro is not null) or
      (new.bairro is not null and old.bairro is not null and new.bairro <> old.bairro)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BAIRRO', old.bairro, new.bairro);

  if ((old.cep is null and new.cep is not null) or
      (new.cep is null and old.cep is not null) or
      (new.cep is not null and old.cep is not null and new.cep <> old.cep)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CEP', old.cep, new.cep);

  if ((old.cidade is null and new.cidade is not null) or
      (new.cidade is null and old.cidade is not null) or
      (new.cidade is not null and old.cidade is not null and new.cidade <> old.cidade)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'CIDADE', old.cidade, new.cidade);

  if ((old.uf is null and new.uf is not null) or
      (new.uf is null and old.uf is not null) or
      (new.uf is not null and old.uf is not null and new.uf <> old.uf)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'UF', old.uf, new.uf);

  if ((old.fone is null and new.fone is not null) or
      (new.fone is null and old.fone is not null) or
      (new.fone is not null and old.fone is not null and new.fone <> old.fone)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONE', old.fone, new.fone);

  if ((old.fonecel is null and new.fonecel is not null) or
      (new.fonecel is null and old.fonecel is not null) or
      (new.fonecel is not null and old.fonecel is not null and new.fonecel <> old.fonecel)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECEL', old.fonecel, new.fonecel);

  if ((old.fonecomerc is null and new.fonecomerc is not null) or
      (new.fonecomerc is null and old.fonecomerc is not null) or
      (new.fonecomerc is not null and old.fonecomerc is not null and new.fonecomerc <> old.fonecomerc)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'FONECOMERC', old.fonecomerc, new.fonecomerc);

  if ((old.email is null and new.email is not null) or
      (new.email is null and old.email is not null) or
      (new.email is not null and old.email is not null and new.email <> old.email)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'EMAIL', old.email, new.email);

  if ((old.site is null and new.site is not null) or
      (new.site is null and old.site is not null) or
      (new.site is not null and old.site is not null and new.site <> old.site)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'SITE', old.site, new.site);

  if ((old.numero_end is null and new.numero_end is not null) or
      (new.numero_end is null and old.numero_end is not null) or
      (new.numero_end is not null and old.numero_end is not null and new.numero_end <> old.numero_end)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'NUMERO_END', old.numero_end, new.numero_end);

  if ((old.pais_id is null and new.pais_id is not null) or
      (new.pais_id is null and old.pais_id is not null) or
      (new.pais_id is not null and old.pais_id is not null and new.pais_id <> old.pais_id)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'PAIS_ID', old.pais_id, new.pais_id);

  if ((old.valor_limite_compra is null and new.valor_limite_compra is not null) or
      (new.valor_limite_compra is null and old.valor_limite_compra is not null) or
      (new.valor_limite_compra is not null and old.valor_limite_compra is not null and new.valor_limite_compra <> old.valor_limite_compra)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, new.valor_limite_compra);

  if ((old.bloqueado is null and new.bloqueado is not null) or
      (new.bloqueado is null and old.bloqueado is not null) or
      (new.bloqueado is not null and old.bloqueado is not null and new.bloqueado <> old.bloqueado)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO', old.bloqueado, new.bloqueado);

  if ((old.bloqueado_data is null and new.bloqueado_data is not null) or
      (new.bloqueado_data is null and old.bloqueado_data is not null) or
      (new.bloqueado_data is not null and old.bloqueado_data is not null and new.bloqueado_data <> old.bloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, new.bloqueado_data);

  if ((old.bloqueado_motivo is null and new.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is null and old.bloqueado_motivo is not null) or
      (new.bloqueado_motivo is not null and old.bloqueado_motivo is not null and new.bloqueado_motivo <> old.bloqueado_motivo)) then
     insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
            values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, new.bloqueado_motivo);

  if ((old.bloqueado_usuario is null and new.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is null and old.bloqueado_usuario is not null) or
      (new.bloqueado_usuario is not null and old.bloqueado_usuario is not null and new.bloqueado_usuario <> old.bloqueado_usuario)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, new.bloqueado_usuario);

  if ((old.desbloqueado_data is null and new.desbloqueado_data is not null) or
      (new.desbloqueado_data is null and old.desbloqueado_data is not null) or
      (new.desbloqueado_data is not null and old.desbloqueado_data is not null and new.desbloqueado_data <> old.desbloqueado_data)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, new.desbloqueado_data);

  if ((old.dtcad is null and new.dtcad is not null) or
      (new.dtcad is null and old.dtcad is not null) or
      (new.dtcad is not null and old.dtcad is not null and new.dtcad <> old.dtcad)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'DTCAD', old.dtcad, new.dtcad);

  if ((old.vendedor_cod is null and new.vendedor_cod is not null) or
      (new.vendedor_cod is null and old.vendedor_cod is not null) or
      (new.vendedor_cod is not null and old.vendedor_cod is not null and new.vendedor_cod <> old.vendedor_cod)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'VENDEDOR_COD', old.vendedor_cod, new.vendedor_cod);

  if ((old.usuario is null and new.usuario is not null) or
      (new.usuario is null and old.usuario is not null) or
      (new.usuario is not null and old.usuario is not null and new.usuario <> old.usuario)) then
     insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
            values (:tid, 'USUARIO', old.usuario, new.usuario);


end;^

SET TERM ; ^

SET TERM ^ ;

ALTER TRIGGER IBE$TBCLIENTE_AD
as
declare variable tid integer;
begin
  tid = gen_id(ibe$log_tables_gen,1);

  insert into ibe$log_tables (id, table_name, operation, date_time, user_name)
         values (:tid, 'TBCLIENTE', 'D', 'NOW', user);

  insert into ibe$log_keys (log_tables_id, key_field, key_value)
         values (:tid, 'CNPJ', old.cnpj);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CODIGO', old.codigo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PESSOA_FISICA', old.pessoa_fisica, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CNPJ', old.cnpj, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NOME', old.nome, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCEST', old.inscest, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'INSCMUN', old.inscmun, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'ENDER', old.ender, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'COMPLEMENTO', old.complemento, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BAIRRO', old.bairro, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CEP', old.cep, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'CIDADE', old.cidade, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'UF', old.uf, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONE', old.fone, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECEL', old.fonecel, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'FONECOMERC', old.fonecomerc, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'EMAIL', old.email, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'SITE', old.site, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'NUMERO_END', old.numero_end, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'PAIS_ID', old.pais_id, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VALOR_LIMITE_COMPRA', old.valor_limite_compra, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO', old.bloqueado, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_DATA', old.bloqueado_data, null);

  insert into ibe$log_blob_fields (log_tables_id, field_name, old_blob_value, new_blob_value)
         values (:tid, 'BLOQUEADO_MOTIVO', old.bloqueado_motivo, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'BLOQUEADO_USUARIO', old.bloqueado_usuario, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DESBLOQUEADO_DATA', old.desbloqueado_data, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'DTCAD', old.dtcad, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'VENDEDOR_COD', old.vendedor_cod, null);

  insert into ibe$log_fields (log_tables_id, field_name, old_value, new_value)
         values (:tid, 'USUARIO', old.usuario, null);


end;^

SET TERM ; ^




/*------ SYSDBA 04/06/2013 14:15:38 --------*/

ALTER TABLE TBPRODUTO
    ADD USUARIO DMN_VCHAR_50;

COMMENT ON COLUMN TBPRODUTO.USUARIO IS
'Usuario Insercao/Atualizacao';




/*------ SYSDBA 04/06/2013 21:46:42 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_compras_atualizar_estoque for tbcompras
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_produto numeric(15,2);
  declare variable custo_compra numeric(15,2);
  declare variable custo_medio numeric(15,2);
  declare variable preco_venda dmn_money;
  declare variable percentual_markup dmn_percentual_3;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 2)) then
  begin

    -- Incrimentar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
        , coalesce(p.Customedio, 0)
        , p.percentual_marckup
        , p.preco
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
        , Custo_produto
        , Percentual_markup
        , Preco_venda
    do
    begin
      if ( (:Custo_compra > 0) and (:Custo_produto > 0) and (:Estoque > 0) ) then
        Custo_medio = (:Custo_compra + :Custo_produto) / 2;
      else
        Custo_medio = :Custo_compra;

      if ( coalesce(:Percentual_markup, 0) = 0 ) then
--        Percentual_markup = cast( ( ( (:Preco_venda - :Custo_medio) / :Custo_medio) * 100) as numeric(18,3) );
        Percentual_markup = cast( ( ( (:Preco_venda - :Custo_compra) / :Custo_compra) * 100 ) as numeric(18,3) );

      -- Incrementar estoque
      Update TBPRODUTO p Set
          --p.Customedio = :Custo_medio
          p.Customedio = :Custo_compra
        , p.Qtde       = :Estoque + :Quantidade
        , p.percentual_marckup = :Percentual_markup
--        , p.preco_sugerido     = cast( (:Custo_medio + (:Custo_medio * :Percentual_markup)) as numeric(15,2) )
        , p.preco_sugerido     = cast( (:Custo_compra + (:Custo_compra * :Percentual_markup)) as numeric(15,2) )
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TBCOMPRASITENS i Set
          i.Qtdeantes = :Estoque
        , i.Qtdefinal = :Estoque + :Quantidade
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - COMPRA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque + :Quantidade
        , new.Usuario
        , 'Custo Medio no valor de R$ ' || :Custo_medio
      );
    end
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 04/06/2013 21:56:44 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_compras_atualizar_estoque for tbcompras
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_produto numeric(15,2);
  declare variable custo_compra numeric(15,2);
  declare variable custo_medio numeric(15,2);
  declare variable preco_venda dmn_money;
  declare variable percentual_markup dmn_percentual_3;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 2)) then
  begin

    -- Incrimentar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
        , coalesce(p.Customedio, 0)
        , p.percentual_marckup
        , p.preco
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
        , Custo_produto
        , Percentual_markup
        , Preco_venda
    do
    begin
      if ( (:Custo_compra > 0) and (:Custo_produto > 0) and (:Estoque > 0) ) then
        Custo_medio = (:Custo_compra + :Custo_produto) / 2;
      else
        Custo_medio = :Custo_compra;

      if ( coalesce(:Percentual_markup, 0) = 0 ) then
--        Percentual_markup = cast( ( ( (:Preco_venda - :Custo_medio) / :Custo_medio) * 100) as numeric(18,3) );
        Percentual_markup = cast( ( ( (:Preco_venda - :Custo_compra) / :Custo_compra) * 100 ) as numeric(18,3) );

      -- Incrementar estoque
      Update TBPRODUTO p Set
          --p.Customedio = :Custo_medio
          p.Customedio = :Custo_compra
        , p.Qtde       = :Estoque + :Quantidade
        , p.percentual_marckup = :Percentual_markup
--        , p.preco_sugerido     = cast( (:Custo_medio + (:Custo_medio * :Percentual_markup / 100)) as numeric(15,2) )
        , p.preco_sugerido     = cast( (:Custo_compra + (:Custo_compra * :Percentual_markup / 100)) as numeric(15,2) )
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TBCOMPRASITENS i Set
          i.Qtdeantes = :Estoque
        , i.Qtdefinal = :Estoque + :Quantidade
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - COMPRA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque + :Quantidade
        , new.Usuario
        , 'Custo Medio no valor de R$ ' || :Custo_medio
      );
    end
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 06/06/2013 11:08:55 --------*/

ALTER TABLE TBPRODUTO
    ADD PERCENTUAL_MARGEM DMN_PERCENTUAL_3;

COMMENT ON COLUMN TBPRODUTO.PERCENTUAL_MARCKUP IS
'Percentual Marckup c/ 3 casas decimais.

Sugestao de composicao:
Percentual Marckup = ((Valor de Venda - Custo de Entrada) / Custo de Entrada) * 100';

COMMENT ON COLUMN TBPRODUTO.PERCENTUAL_MARGEM IS
'Percentual de Margem Aplicada p/ Venda c/ 3 casas decimais.

Sugestao de composicao:
Percentual Margem = ((Lucro Desejado + Despesas Administrativas e de Venda) / Custo de Entrada) * 100';

COMMENT ON COLUMN TBPRODUTO.PRECO_SUGERIDO IS
'Preco Venda (Sugerido).

Composicao:
Preco Sugerido = Custo de Entrada * Percentual Margem / 100';

alter table TBPRODUTO
alter CODIGO position 1;

alter table TBPRODUTO
alter COD position 2;

alter table TBPRODUTO
alter DESCRI position 3;

alter table TBPRODUTO
alter APRESENTACAO position 4;

alter table TBPRODUTO
alter DESCRI_APRESENTACAO position 5;

alter table TBPRODUTO
alter MODELO position 6;

alter table TBPRODUTO
alter PRECO position 7;

alter table TBPRODUTO
alter PRECO_PROMOCAO position 8;

alter table TBPRODUTO
alter REFERENCIA position 9;

alter table TBPRODUTO
alter SECAO position 10;

alter table TBPRODUTO
alter QTDE position 11;

alter table TBPRODUTO
alter UNIDADE position 12;

alter table TBPRODUTO
alter ESTOQMIN position 13;

alter table TBPRODUTO
alter CODGRUPO position 14;

alter table TBPRODUTO
alter CODFABRICANTE position 15;

alter table TBPRODUTO
alter CUSTOMEDIO position 16;

alter table TBPRODUTO
alter PERCENTUAL_MARCKUP position 17;

alter table TBPRODUTO
alter PERCENTUAL_MARGEM position 18;

alter table TBPRODUTO
alter PRECO_SUGERIDO position 19;

alter table TBPRODUTO
alter CODEMP position 20;

alter table TBPRODUTO
alter CODSECAO position 21;

alter table TBPRODUTO
alter CODORIGEM position 22;

alter table TBPRODUTO
alter CODTRIBUTACAO position 23;

alter table TBPRODUTO
alter CST position 24;

alter table TBPRODUTO
alter CSOSN position 25;

alter table TBPRODUTO
alter CST_PIS position 26;

alter table TBPRODUTO
alter CST_COFINS position 27;

alter table TBPRODUTO
alter NCM_SH position 28;

alter table TBPRODUTO
alter CODCFOP position 29;

alter table TBPRODUTO
alter CODBARRA_EAN position 30;

alter table TBPRODUTO
alter CODUNIDADE position 31;

alter table TBPRODUTO
alter ALIQUOTA_TIPO position 32;

alter table TBPRODUTO
alter ALIQUOTA position 33;

alter table TBPRODUTO
alter ALIQUOTA_CSOSN position 34;

alter table TBPRODUTO
alter ALIQUOTA_PIS position 35;

alter table TBPRODUTO
alter ALIQUOTA_COFINS position 36;

alter table TBPRODUTO
alter VALOR_IPI position 37;

alter table TBPRODUTO
alter RESERVA position 38;

alter table TBPRODUTO
alter PRODUTO_NOVO position 39;

alter table TBPRODUTO
alter COR_VEICULO position 40;

alter table TBPRODUTO
alter COMBUSTIVEL_VEICULO position 41;

alter table TBPRODUTO
alter TIPO_VEICULO position 42;

alter table TBPRODUTO
alter ANO_MODELO_VEICULO position 43;

alter table TBPRODUTO
alter ANO_FABRICACAO_VEICULO position 44;

alter table TBPRODUTO
alter RENAVAM_VEICULO position 45;

alter table TBPRODUTO
alter CHASSI_VEICULO position 46;

alter table TBPRODUTO
alter KILOMETRAGEM_VEICULO position 47;

alter table TBPRODUTO
alter SITUACAO_ATUAL_VEICULO position 48;

alter table TBPRODUTO
alter SITUACAO_HISTORICO_VEICULO position 49;

alter table TBPRODUTO
alter PERCENTUAL_REDUCAO_BC position 50;

alter table TBPRODUTO
alter USUARIO position 51;




/*------ SYSDBA 06/06/2013 11:11:17 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_compras_atualizar_estoque for tbcompras
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_produto numeric(15,2);
  declare variable custo_compra numeric(15,2);
  declare variable custo_medio numeric(15,2);
  declare variable preco_venda dmn_money;
  declare variable percentual_markup dmn_percentual_3;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 2)) then
  begin

    -- Incrimentar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
        , coalesce(p.Customedio, 0)
        , p.percentual_marckup
        , p.preco
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
        , Custo_produto
        , Percentual_markup
        , Preco_venda
    do
    begin
      if ( (:Custo_compra > 0) and (:Custo_produto > 0) and (:Estoque > 0) ) then
        Custo_medio = (:Custo_compra + :Custo_produto) / 2;
      else
        Custo_medio = :Custo_compra;

--      Percentual_markup = cast( ( ( (:Preco_venda - :Custo_medio) / :Custo_medio) * 100) as numeric(18,3) );
      Percentual_markup = cast( ( ( (:Preco_venda - :Custo_compra) / :Custo_compra) * 100 ) as numeric(18,3) );

      -- Incrementar estoque
      Update TBPRODUTO p Set
          --p.Customedio = :Custo_medio
          p.Customedio = :Custo_compra
        , p.Qtde       = :Estoque + :Quantidade
        , p.percentual_marckup = :Percentual_markup
--        , p.preco_sugerido     = cast( (:Custo_medio + (:Custo_medio * :Percentual_markup / 100)) as numeric(15,2) )
        , p.preco_sugerido     = cast( (:Custo_compra + (:Custo_compra * :Percentual_markup / 100)) as numeric(15,2) )
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TBCOMPRASITENS i Set
          i.Qtdeantes = :Estoque
        , i.Qtdefinal = :Estoque + :Quantidade
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - COMPRA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque + :Quantidade
        , new.Usuario
        , 'Custo Medio no valor de R$ ' || :Custo_medio
      );
    end
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 06/06/2013 11:12:02 --------*/

COMMENT ON COLUMN TBPRODUTO.PERCENTUAL_MARCKUP IS
'Percentual de Marckup c/ 3 casas decimais.

Sugestao de composicao:
Percentual Marckup = ((Valor de Venda - Custo de Entrada) / Custo de Entrada) * 100';




/*------ SYSDBA 10/07/2013 11:25:45 --------*/

ALTER TABLE TBPRODUTO
    ADD FRACIONADOR DMN_PERCENTUAL_3 DEFAULT 1,
    ADD VENDA_FRACIONADA DMN_LOGICO DEFAULT 0,
    ADD CODUNIDADE_FRACIONADA DMN_SMALLINT_N;

COMMENT ON COLUMN TBPRODUTO.FRACIONADOR IS
'Fracionador.';

COMMENT ON COLUMN TBPRODUTO.VENDA_FRACIONADA IS
'Venda Fracionada:
0 - Nao
1 - Sim';

COMMENT ON COLUMN TBPRODUTO.CODUNIDADE_FRACIONADA IS
'Unidade da Fracao.';

alter table TBPRODUTO
alter CODIGO position 1;

alter table TBPRODUTO
alter COD position 2;

alter table TBPRODUTO
alter DESCRI position 3;

alter table TBPRODUTO
alter APRESENTACAO position 4;

alter table TBPRODUTO
alter DESCRI_APRESENTACAO position 5;

alter table TBPRODUTO
alter MODELO position 6;

alter table TBPRODUTO
alter PRECO position 7;

alter table TBPRODUTO
alter PRECO_PROMOCAO position 8;

alter table TBPRODUTO
alter REFERENCIA position 9;

alter table TBPRODUTO
alter SECAO position 10;

alter table TBPRODUTO
alter QTDE position 11;

alter table TBPRODUTO
alter FRACIONADOR position 12;

alter table TBPRODUTO
alter VENDA_FRACIONADA position 13;

alter table TBPRODUTO
alter CODUNIDADE_FRACIONADA position 14;

alter table TBPRODUTO
alter UNIDADE position 15;

alter table TBPRODUTO
alter ESTOQMIN position 16;

alter table TBPRODUTO
alter CODGRUPO position 17;

alter table TBPRODUTO
alter CODFABRICANTE position 18;

alter table TBPRODUTO
alter CUSTOMEDIO position 19;

alter table TBPRODUTO
alter PERCENTUAL_MARCKUP position 20;

alter table TBPRODUTO
alter PERCENTUAL_MARGEM position 21;

alter table TBPRODUTO
alter PRECO_SUGERIDO position 22;

alter table TBPRODUTO
alter CODEMP position 23;

alter table TBPRODUTO
alter CODSECAO position 24;

alter table TBPRODUTO
alter CODORIGEM position 25;

alter table TBPRODUTO
alter CODTRIBUTACAO position 26;

alter table TBPRODUTO
alter CST position 27;

alter table TBPRODUTO
alter CSOSN position 28;

alter table TBPRODUTO
alter CST_PIS position 29;

alter table TBPRODUTO
alter CST_COFINS position 30;

alter table TBPRODUTO
alter NCM_SH position 31;

alter table TBPRODUTO
alter CODCFOP position 32;

alter table TBPRODUTO
alter CODBARRA_EAN position 33;

alter table TBPRODUTO
alter CODUNIDADE position 34;

alter table TBPRODUTO
alter ALIQUOTA_TIPO position 35;

alter table TBPRODUTO
alter ALIQUOTA position 36;

alter table TBPRODUTO
alter ALIQUOTA_CSOSN position 37;

alter table TBPRODUTO
alter ALIQUOTA_PIS position 38;

alter table TBPRODUTO
alter ALIQUOTA_COFINS position 39;

alter table TBPRODUTO
alter VALOR_IPI position 40;

alter table TBPRODUTO
alter RESERVA position 41;

alter table TBPRODUTO
alter PRODUTO_NOVO position 42;

alter table TBPRODUTO
alter COR_VEICULO position 43;

alter table TBPRODUTO
alter COMBUSTIVEL_VEICULO position 44;

alter table TBPRODUTO
alter TIPO_VEICULO position 45;

alter table TBPRODUTO
alter ANO_MODELO_VEICULO position 46;

alter table TBPRODUTO
alter ANO_FABRICACAO_VEICULO position 47;

alter table TBPRODUTO
alter RENAVAM_VEICULO position 48;

alter table TBPRODUTO
alter CHASSI_VEICULO position 49;

alter table TBPRODUTO
alter KILOMETRAGEM_VEICULO position 50;

alter table TBPRODUTO
alter SITUACAO_ATUAL_VEICULO position 51;

alter table TBPRODUTO
alter SITUACAO_HISTORICO_VEICULO position 52;

alter table TBPRODUTO
alter PERCENTUAL_REDUCAO_BC position 53;

alter table TBPRODUTO
alter USUARIO position 54;


/*------ SYSDBA 10/07/2013 11:26:44 --------*/

--update TBVENDAS v set v.nfe_modalidade_frete = 3 where v.nfe_modalidade_frete is null
/*
Select
    p.codigo
  , p.descri
  , p.customedio
  , p.preco
  , p.percentual_marckup
  , p.preco_sugerido
  , cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) ) as tmp_percentual_marckup
  , cast( (p.customedio + (p.customedio * ((p.preco - p.customedio) / p.customedio))) as numeric(15,2) ) as tmp_preco_sugerido
from TBPRODUTO p
--where (p.percentual_marckup is null)
--  and (p.preco_sugerido is null)
*/

/*

Update TBPRODUTO p Set
    p.percentual_marckup = cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) )
  , p.percentual_margem  = cast( (((p.preco - p.customedio) / p.customedio) * 100) as numeric(18,3) )
  , p.preco_sugerido     = cast( (p.customedio + (p.customedio * ((p.preco - p.customedio) / p.customedio))) as numeric(15,2) )
where (p.percentual_marckup is null)
  and (p.preco_sugerido is null)
  and (coalesce(p.customedio, 0) > 0)

*/

Update TBPRODUTO p Set
  p.fracionador = 1
where coalesce(p.fracionador, 0) = 0;
/*------ SYSDBA 10/07/2013 11:26:49 --------*/

COMMIT WORK;

/*------ SYSDBA 10/07/2013 11:27:12 --------*/

Update TBPRODUTO p Set
    p.fracionador = 1
  , p.venda_fracionada = 0
;
/*------ SYSDBA 10/07/2013 11:27:17 --------*/

COMMIT WORK;

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 76, column 28.
(.

*/



/*------ SYSDBA 15/07/2013 22:34:17 --------*/

CREATE DOMAIN DMN_NUMERO AS
NUMERIC(18,4);COMMENT ON DOMAIN DMN_NUMERO IS 'Numero longo c/ ponto flutuante.';




/*------ SYSDBA 15/07/2013 22:54:51 --------*/

CREATE TABLE TBPRODUTO_ROTATIVIDADE (
    COD_PRODUTO DMN_VCHAR_10_KEY NOT NULL,
    "01_COMPRA_QTDE" DMN_NUMERO,
    "01_COMPRA_VALOR" DMN_NUMERO,
    "01_VENDA_QTDE" DMN_NUMERO,
    "01_VENDA_VALOR" DMN_NUMERO);

ALTER TABLE TBPRODUTO_ROTATIVIDADE
ADD CONSTRAINT PK_TBPRODUTO_ROTATIVIDADE
PRIMARY KEY (COD_PRODUTO);

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.COD_PRODUTO IS
'Produto.';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."01_COMPRA_QTDE" IS
'Quantidade compra (0 a 1 mes).';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."01_COMPRA_VALOR" IS
'Valor compra (0 a 1 mes).';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."01_VENDA_QTDE" IS
'Quantidade venda (0 a 1 mes).';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."01_VENDA_VALOR" IS
'Valor venda (0 a 1 mes).';




/*------ SYSDBA 15/07/2013 22:57:30 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
    ADD "03_COMPRA_QTDE" DMN_NUMERO;

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."03_COMPRA_QTDE" IS
'Quantidade compra (1 a 3 mes).';



/*------ 15/07/2013 23:02:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "06_COMPRA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:02:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "09_COMPRA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:02:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "12_COMPRA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:02:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "99_COMPRA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:02:06 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_COMPRA_QTDE" IS 'Quantidade compra (3 a 6 meses).';

/*------ 15/07/2013 23:02:06 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_COMPRA_QTDE" IS 'Quantidade compra (6 a 9 meses).';

/*------ 15/07/2013 23:02:06 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_COMPRA_QTDE" IS 'Quantidade compra (9 a 12 meses).';

/*------ 15/07/2013 23:02:06 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_COMPRA_QTDE" IS 'Quantidade compra (+12 meses).';


/*------ SYSDBA 15/07/2013 23:02:28 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."03_COMPRA_QTDE" IS
'Quantidade compra (1 a 3 meses).';




/*------ SYSDBA 15/07/2013 23:04:36 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
    ADD "03_COMPRA_VALOR" DMN_NUMERO;

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."03_COMPRA_VALOR" IS
'Valor compra (1 a 3 meses).';

alter table TBPRODUTO_ROTATIVIDADE
alter COD_PRODUTO position 1;

alter table TBPRODUTO_ROTATIVIDADE
alter "01_COMPRA_QTDE" position 2;

alter table TBPRODUTO_ROTATIVIDADE
alter "01_COMPRA_VALOR" position 3;

alter table TBPRODUTO_ROTATIVIDADE
alter "01_VENDA_QTDE" position 4;

alter table TBPRODUTO_ROTATIVIDADE
alter "01_VENDA_VALOR" position 5;

alter table TBPRODUTO_ROTATIVIDADE
alter "03_COMPRA_QTDE" position 6;

alter table TBPRODUTO_ROTATIVIDADE
alter "03_COMPRA_VALOR" position 7;

alter table TBPRODUTO_ROTATIVIDADE
alter "06_COMPRA_QTDE" position 8;

alter table TBPRODUTO_ROTATIVIDADE
alter "09_COMPRA_QTDE" position 9;

alter table TBPRODUTO_ROTATIVIDADE
alter "12_COMPRA_QTDE" position 10;

alter table TBPRODUTO_ROTATIVIDADE
alter "99_COMPRA_QTDE" position 11;


/*------ SYSDBA 15/07/2013 23:08:10 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "06_COMPRA_VALOR" DMN_NUMERO;
ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "09_COMPRA_VALOR" DMN_NUMERO;
ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "12_COMPRA_VALOR" DMN_NUMERO;
ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "99_COMPRA_VALOR" DMN_NUMERO;


COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_COMPRA_VALOR" IS 'Valor compra (3 a 6 meses).';
COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_COMPRA_VALOR" IS 'Valor compra (6 a 9 meses).';
COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_COMPRA_VALOR" IS 'Valor compra (9 a 12 meses).';
COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_COMPRA_VALOR" IS 'Valor compra (+12 meses).';
/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 2, column 1.
ALTER.

*/


/*------ 15/07/2013 23:08:28 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "06_COMPRA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:08:28 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "09_COMPRA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:08:28 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "12_COMPRA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:08:28 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "99_COMPRA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:08:28 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_COMPRA_VALOR" IS 'Valor compra (3 a 6 meses).';

/*------ 15/07/2013 23:08:28 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_COMPRA_VALOR" IS 'Valor compra (6 a 9 meses).';

/*------ 15/07/2013 23:08:28 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_COMPRA_VALOR" IS 'Valor compra (9 a 12 meses).';

/*------ 15/07/2013 23:08:28 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_COMPRA_VALOR" IS 'Valor compra (+12 meses).';
/*------ SYSDBA 15/07/2013 23:09:09 --------*/

ROLLBACK WORK;


/*------ 15/07/2013 23:09:16 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_COMPRA_VALOR" IS 'Valor compra (3 a 6 meses).';

/*------ 15/07/2013 23:09:16 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_COMPRA_VALOR" IS 'Valor compra (6 a 9 meses).';

/*------ 15/07/2013 23:09:16 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_COMPRA_VALOR" IS 'Valor compra (9 a 12 meses).';

/*------ 15/07/2013 23:09:16 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_COMPRA_VALOR" IS 'Valor compra (+12 meses).';


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COD_PRODUTO position 1;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_QTDE" position 2;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_VALOR" position 3;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_QTDE" position 4;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_VALOR" position 5;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_QTDE" position 6;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_VALOR" position 7;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_QTDE" position 8;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_VALOR" position 9;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_QTDE" position 10;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_VALOR" position 11;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_QTDE" position 12;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_VALOR" position 13;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_QTDE" position 14;


/*------ SYSDBA 15/07/2013 23:09:57 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_VALOR" position 15;

/*------ 15/07/2013 23:11:17 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "06_VENDA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:11:17 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "09_VENDA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:11:17 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "12_VENDA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:11:17 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "99_VENDA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:11:17 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_VENDA_QTDE" IS 'Quantidade venda (3 a 6 meses).';

/*------ 15/07/2013 23:11:17 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_VENDA_QTDE" IS 'Quantidade venda (6 a 9 meses).';

/*------ 15/07/2013 23:11:17 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_VENDA_QTDE" IS 'Quantidade venda (9 a 12 meses).';

/*------ 15/07/2013 23:11:17 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_VENDA_QTDE" IS 'Quantidade venda (+12 meses).';


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COD_PRODUTO position 1;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_QTDE" position 2;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_VALOR" position 3;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_QTDE" position 4;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_VALOR" position 5;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_QTDE" position 6;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_VALOR" position 7;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_QTDE" position 8;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_VALOR" position 9;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_VENDA_QTDE" position 10;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_QTDE" position 11;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_VALOR" position 12;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_VENDA_QTDE" position 13;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_QTDE" position 14;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_VALOR" position 15;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_VENDA_QTDE" position 16;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_QTDE" position 17;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_VALOR" position 18;


/*------ SYSDBA 15/07/2013 23:11:52 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_VENDA_QTDE" position 19;

/*------ 15/07/2013 23:12:47 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "03_VENDA_QTDE" DMN_NUMERO;

/*------ 15/07/2013 23:12:47 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."03_VENDA_QTDE" IS 'Quantidade venda (1 a 3 meses).';

/*------ 15/07/2013 23:12:47 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_VENDA_QTDE" IS 'Quantidade venda (3 a 6 meses).';

/*------ 15/07/2013 23:12:47 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_VENDA_QTDE" IS 'Quantidade venda (6 a 9 meses).';

/*------ 15/07/2013 23:12:47 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_VENDA_QTDE" IS 'Quantidade venda (9 a 12 meses).';

/*------ 15/07/2013 23:12:47 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_VENDA_QTDE" IS 'Quantidade venda (+12 meses).';


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COD_PRODUTO position 1;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_QTDE" position 2;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_VALOR" position 3;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_QTDE" position 4;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_VALOR" position 5;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_QTDE" position 6;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_VALOR" position 7;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_VENDA_QTDE" position 8;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_QTDE" position 9;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_VALOR" position 10;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_VENDA_QTDE" position 11;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_QTDE" position 12;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_VALOR" position 13;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_VENDA_QTDE" position 14;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_QTDE" position 15;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_VALOR" position 16;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_VENDA_QTDE" position 17;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_QTDE" position 18;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_VALOR" position 19;


/*------ SYSDBA 15/07/2013 23:13:09 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_VENDA_QTDE" position 20;

/*------ 15/07/2013 23:20:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "03_VENDA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:20:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "06_VENDA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:20:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "09_VENDA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:20:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "12_VENDA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:20:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ADD "99_VENDA_VALOR" DMN_NUMERO;

/*------ 15/07/2013 23:20:19 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."03_VENDA_VALOR" IS 'Valor venda (1 a 3 meses).';

/*------ 15/07/2013 23:20:19 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."06_VENDA_VALOR" IS 'Valor venda (3 a 6 meses).';

/*------ 15/07/2013 23:20:19 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."09_VENDA_VALOR" IS 'Valor venda (6 a 9 meses).';

/*------ 15/07/2013 23:20:19 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."12_VENDA_VALOR" IS 'Valor venda (9 a 12 meses).';

/*------ 15/07/2013 23:20:19 --------*/

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE."99_VENDA_VALOR" IS 'Valor venda (+12 meses).';


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COD_PRODUTO position 1;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_QTDE" position 2;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_COMPRA_VALOR" position 3;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_QTDE" position 4;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "01_VENDA_VALOR" position 5;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_QTDE" position 6;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_COMPRA_VALOR" position 7;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_VENDA_QTDE" position 8;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "03_VENDA_VALOR" position 9;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_QTDE" position 10;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_COMPRA_VALOR" position 11;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_VENDA_QTDE" position 12;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "06_VENDA_VALOR" position 13;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_QTDE" position 14;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_COMPRA_VALOR" position 15;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_VENDA_QTDE" position 16;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "09_VENDA_VALOR" position 17;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_QTDE" position 18;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_COMPRA_VALOR" position 19;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_VENDA_QTDE" position 20;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "12_VENDA_VALOR" position 21;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_QTDE" position 22;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_COMPRA_VALOR" position 23;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_VENDA_QTDE" position 24;


/*------ SYSDBA 15/07/2013 23:20:49 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column "99_VENDA_VALOR" position 25;


/*------ SYSDBA 15/07/2013 23:44:33 --------*/

SET TERM ^ ;

create or alter procedure SET_PRODUTO_ROTATIVIDADE (
    PRODUTO varchar(10),
    DATA_INICIAL date,
    DATA_FINAL date)
returns (
    COMPRA_QTDE numeric(18,4),
    COMPRA_VALOR numeric(18,4),
    VENDA_QTDE numeric(18,4),
    VENDA_VALOR numeric(18,4))
as
begin
  /* Buscar compras */
  Select
      sum(c.qtde)
    , sum(c.qtde * c.customedio)
  from TBCOMPRAS cc
    inner join TBCOMPRASITENS c on (cc.ano = c.ano and cc.codcontrol = c.codcontrol)
  where cc.dtent between :data_inicial and :data_final
    and cc.status in (2, 4) -- Finalizada, NF-e
    and c.codprod = :produto
  Into
      compra_qtde
    , compra_valor;

  /* Buscar vendas */
  Select
      sum(v.qtde)
    , sum(v.qtde * v.pfinal)
  from TBVENDAS vv
    inner join TVENDASITENS v on (vv.ano = v.ano and vv.codcontrol = v.codcontrol)
  where vv.dtvenda between :data_inicial and :data_final
    and vv.status in (3, 4) -- Finalizada, NF-e
    and v.codprod = :produto
  Into
      venda_qtde
    , venda_valor;

  suspend;
end^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE SET_PRODUTO_ROTATIVIDADE TO "PUBLIC";


/*------ 15/07/2013 23:48:21 --------*/

SET TERM ^ ;

create or alter procedure GET_PRODUTO_ROTATIVIDADE (
    PRODUTO varchar(10),
    DATA_INICIAL date,
    DATA_FINAL date)
returns (
    COMPRA_QTDE numeric(18,4),
    COMPRA_VALOR numeric(18,4),
    VENDA_QTDE numeric(18,4),
    VENDA_VALOR numeric(18,4))
as
begin
  /* Buscar compras */
  Select
      sum(c.qtde)
    , sum(c.qtde * c.customedio)
  from TBCOMPRAS cc
    inner join TBCOMPRASITENS c on (cc.ano = c.ano and cc.codcontrol = c.codcontrol)
  where cc.dtent between :data_inicial and :data_final
    and cc.status in (2, 4) -- Finalizada, NF-e
    and c.codprod = :produto
  Into
      compra_qtde
    , compra_valor;

  /* Buscar vendas */
  Select
      sum(v.qtde)
    , sum(v.qtde * v.pfinal)
  from TBVENDAS vv
    inner join TVENDASITENS v on (vv.ano = v.ano and vv.codcontrol = v.codcontrol)
  where vv.dtvenda between :data_inicial and :data_final
    and vv.status in (3, 4) -- Finalizada, NF-e
    and v.codprod = :produto
  Into
      venda_qtde
    , venda_valor;

  suspend;
end^

/*------ 15/07/2013 23:48:21 --------*/

SET TERM ; ^

GRANT SELECT ON TBCOMPRAS TO PROCEDURE GET_PRODUTO_ROTATIVIDADE;

/*------ 15/07/2013 23:48:21 --------*/

GRANT SELECT ON TBCOMPRASITENS TO PROCEDURE GET_PRODUTO_ROTATIVIDADE;

/*------ 15/07/2013 23:48:21 --------*/

GRANT SELECT ON TBVENDAS TO PROCEDURE GET_PRODUTO_ROTATIVIDADE;

/*------ 15/07/2013 23:48:21 --------*/

GRANT SELECT ON TVENDASITENS TO PROCEDURE GET_PRODUTO_ROTATIVIDADE;

/*------ 15/07/2013 23:48:21 --------*/

GRANT EXECUTE ON PROCEDURE GET_PRODUTO_ROTATIVIDADE TO "PUBLIC";

/*------ 15/07/2013 23:48:21 --------*/

GRANT EXECUTE ON PROCEDURE GET_PRODUTO_ROTATIVIDADE TO SYSDBA;


/*------ SYSDBA 15/07/2013 23:48:33 --------*/

DROP PROCEDURE SET_PRODUTO_ROTATIVIDADE;




/*------ SYSDBA 16/07/2013 00:31:06 --------*/

COMMENT ON COLUMN TBPRODUTO.CODGRUPO IS
'Grupo.';




/*------ SYSDBA 18/07/2013 20:08:31 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
    ADD PROCESSO_DATA DMN_DATE,
    ADD PROCESSO_HORA DMN_TIME,
    ADD PROCESSO_USUARIO DMN_VCHAR_50;

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.PROCESSO_DATA IS
'Data do processo.';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.PROCESSO_HORA IS
'Hora do processo.';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.PROCESSO_USUARIO IS
'Usuario do processo.';


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 43, column 40.
rt.

*/

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 45, column 9.
01.

*/



/*------ SYSDBA 18/07/2013 20:15:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "01_COMPRA_QTDE" TO "_01_COMPRA_QTDE";




/*------ SYSDBA 18/07/2013 20:15:19 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "_01_COMPRA_QTDE" TO COMPRA_QTDE;




/*------ SYSDBA 18/07/2013 20:15:33 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER COMPRA_QTDE TO COMPRA_QTDE_01;




/*------ SYSDBA 18/07/2013 20:15:41 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "01_COMPRA_VALOR" TO COMPRA_VALOR_01;




/*------ SYSDBA 18/07/2013 20:15:49 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "01_VENDA_QTDE" TO VENDA_QTDE_01;




/*------ SYSDBA 18/07/2013 20:15:56 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "01_VENDA_VALOR" TO VENDA_VALOR_01;




/*------ SYSDBA 18/07/2013 20:16:04 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "03_COMPRA_QTDE" TO COMPRA_QTDE_03;




/*------ SYSDBA 18/07/2013 20:16:12 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "03_COMPRA_VALOR" TO COMPRA_VALOR_03;




/*------ SYSDBA 18/07/2013 20:16:18 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "03_VENDA_QTDE" TO VENDA_QTDE_03;




/*------ SYSDBA 18/07/2013 20:16:28 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "03_VENDA_VALOR" TO VENDA_VALOR_03;




/*------ SYSDBA 18/07/2013 20:16:36 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "06_COMPRA_QTDE" TO COMPRA_QTDE_06;




/*------ SYSDBA 18/07/2013 20:16:42 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "06_COMPRA_VALOR" TO COMPRA_VALOR_06;




/*------ SYSDBA 18/07/2013 20:16:47 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "06_VENDA_QTDE" TO VENDA_QTDE_06;




/*------ SYSDBA 18/07/2013 20:16:52 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "06_VENDA_VALOR" TO VENDA_VALOR_06;




/*------ SYSDBA 18/07/2013 20:17:00 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "09_COMPRA_QTDE" TO COMPRA_QTDE_09;




/*------ SYSDBA 18/07/2013 20:17:05 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "09_COMPRA_VALOR" TO COMPRA_VALOR_09;




/*------ SYSDBA 18/07/2013 20:17:10 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "09_VENDA_QTDE" TO VENDA_QTDE_09;




/*------ SYSDBA 18/07/2013 20:17:18 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "09_VENDA_VALOR" TO VENDA_VALOR_09;




/*------ SYSDBA 18/07/2013 20:17:25 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "12_COMPRA_QTDE" TO COMPRA_QTDE_12;




/*------ SYSDBA 18/07/2013 20:17:30 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "12_COMPRA_VALOR" TO COMPRA_VALOR_12;




/*------ SYSDBA 18/07/2013 20:17:35 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "12_VENDA_QTDE" TO VENDA_QTDE_12;




/*------ SYSDBA 18/07/2013 20:17:45 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "12_VENDA_VALOR" TO VENDA_VALOR_12;




/*------ SYSDBA 18/07/2013 20:17:53 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "99_COMPRA_QTDE" TO COMPRA_QTDE_99;




/*------ SYSDBA 18/07/2013 20:17:57 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "99_COMPRA_VALOR" TO COMPRA_VALOR_99;




/*------ SYSDBA 18/07/2013 20:18:02 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "99_VENDA_QTDE" TO VENDA_QTDE_99;




/*------ SYSDBA 18/07/2013 20:18:06 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE ALTER "99_VENDA_VALOR" TO VENDA_VALOR_99;


/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
TMP_COMPRA_QTDE.
At line 51, column 9.

*/



/*------ SYSDBA 18/07/2013 20:37:41 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure GET_PRODUTO_ROTATIVIDADE (
    PRODUTO varchar(10),
    DATA_INICIAL date,
    DATA_FINAL date)
returns (
    COMPRA_QTDE numeric(18,4),
    COMPRA_VALOR numeric(18,4),
    VENDA_QTDE numeric(18,4),
    VENDA_VALOR numeric(18,4))
as
begin
  /* Buscar compras */
  Select
      sum(c.qtde)
    , sum(c.qtde * c.customedio)
  from TBCOMPRAS cc
    inner join TBCOMPRASITENS c on (c.ano = cc.ano and c.codcontrol = cc.codcontrol)
  where cc.dtent between :data_inicial and :data_final
    and cc.status in (2, 4) -- Finalizada, NF-e
    and c.codprod = :produto
  Into
      compra_qtde
    , compra_valor;

  /* Buscar vendas */
  Select
      sum(v.qtde)
    , sum(v.qtde * v.pfinal)
  from TBVENDAS vv
    inner join TVENDASITENS v on (vv.ano = v.ano and vv.codcontrol = v.codcontrol)
  where vv.dtvenda between :data_inicial and :data_final
    and vv.status in (3, 4) -- Finalizada, NF-e
    and v.codprod = :produto
  Into
      venda_qtde
    , venda_valor;

  suspend;
end^

SET TERM ; ^




/*------ SYSDBA 18/07/2013 20:37:59 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure GET_PRODUTO_ROTATIVIDADE (
    PRODUTO varchar(10),
    DATA_INICIAL date,
    DATA_FINAL date)
returns (
    COMPRA_QTDE numeric(18,4),
    COMPRA_VALOR numeric(18,4),
    VENDA_QTDE numeric(18,4),
    VENDA_VALOR numeric(18,4))
as
begin
  /* Buscar compras */
  Select
      sum(c.qtde)
    , sum(c.qtde * c.customedio)
  from TBCOMPRAS cc
    inner join TBCOMPRASITENS c on (c.ano = cc.ano and c.codcontrol = cc.codcontrol)
  where cc.dtent between :data_inicial and :data_final
    and cc.status in (2, 4) -- Finalizada, NF-e
    and c.codprod = :produto
  Into
      compra_qtde
    , compra_valor;

  /* Buscar vendas */
  Select
      sum(v.qtde)
    , sum(v.qtde * v.pfinal)
  from TBVENDAS vv
    inner join TVENDASITENS v on (v.ano = vv.ano and v.codcontrol = vv.codcontrol)
  where vv.dtvenda between :data_inicial and :data_final
    and vv.status in (3, 4) -- Finalizada, NF-e
    and v.codprod = :produto
  Into
      venda_qtde
    , venda_valor;

  suspend;
end^

SET TERM ; ^




/*------ SYSDBA 18/07/2013 20:47:06 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure GET_PRODUTO_ROTATIVIDADE (
    PRODUTO varchar(10),
    DATA_INICIAL date,
    DATA_FINAL date)
returns (
    COMPRA_QTDE numeric(18,4),
    COMPRA_VALOR numeric(18,4),
    VENDA_QTDE numeric(18,4),
    VENDA_VALOR numeric(18,4))
as
begin
  /* Buscar compras */
  Select
      sum(c.qtde)
    , sum(c.qtde * c.customedio)
  from TBCOMPRAS cc
    inner join TBCOMPRASITENS c on (c.ano = cc.ano and c.codcontrol = cc.codcontrol)
  where cc.dtent between :data_inicial and :data_final
    and cc.status in (2, 4) -- Finalizada, NF-e
    and c.codprod = :produto
  Into
      compra_qtde
    , compra_valor;

  /* Buscar vendas */
  Select
      sum(v.qtde)
    , sum(v.qtde * v.pfinal)
  from TBVENDAS vv
    inner join TVENDASITENS v on (v.ano = vv.ano and v.codcontrol = vv.codcontrol)
  where cast(vv.dtvenda as date) between :data_inicial and :data_final
    and vv.status in (3, 4) -- Finalizada, NF-e
    and v.codprod = :produto
  Into
      venda_qtde
    , venda_valor;

  suspend;
end^

SET TERM ; ^


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 28, column 3.
Delete.

*/



/*------ SYSDBA 18/07/2013 20:55:52 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
    ADD MOVIMENTADO DMN_LOGICO;

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.MOVIMENTADO IS
'Produto movimentado:
0 - Nao
1 - Sim';




/*------ SYSDBA 18/07/2013 20:55:57 --------*/

UPDATE TBPRODUTO_ROTATIVIDADE
SET MOVIMENTADO = 0;




/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COD_PRODUTO position 1;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_01 position 2;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_01 position 3;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_01 position 4;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_01 position 5;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_03 position 6;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_03 position 7;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_03 position 8;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_03 position 9;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_06 position 10;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_06 position 11;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_06 position 12;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_06 position 13;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_09 position 14;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_09 position 15;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_09 position 16;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_09 position 17;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_12 position 18;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_12 position 19;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_12 position 20;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_12 position 21;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_QTDE_99 position 22;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column COMPRA_VALOR_99 position 23;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_QTDE_99 position 24;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column VENDA_VALOR_99 position 25;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column MOVIMENTADO position 26;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column PROCESSO_DATA position 27;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column PROCESSO_HORA position 28;


/*------ SYSDBA 18/07/2013 20:56:06 --------*/

alter table TBPRODUTO_ROTATIVIDADE
alter column PROCESSO_USUARIO position 29;


/*------ SYSDBA 18/07/2013 20:56:42 --------*/

CREATE INDEX IDX_PRODUTO_ROTATIVIDADE
ON TBPRODUTO_ROTATIVIDADE (MOVIMENTADO);




/*------ SYSDBA 18/07/2013 20:59:26 --------*/

SET TERM ^ ;

CREATE trigger tg_produto_rotatividade_mov for tbproduto_rotatividade
active before insert or update position 0
AS
  declare variable movimento numeric(18,4);
begin
  movimento =
    coalesce(new.compra_qtde_01, 0) + coalesce(new.venda_qtde_01, 0) +
    coalesce(new.compra_qtde_03, 0) + coalesce(new.venda_qtde_03, 0) +
    coalesce(new.compra_qtde_06, 0) + coalesce(new.venda_qtde_06, 0) +
    coalesce(new.compra_qtde_09, 0) + coalesce(new.venda_qtde_09, 0) +
    coalesce(new.compra_qtde_12, 0) + coalesce(new.venda_qtde_12, 0) +
    coalesce(new.compra_qtde_99, 0) + coalesce(new.venda_qtde_99, 0);

  if ( :movimento > 0 ) then
    new.movimentado = 1;
  else
    new.movimentado = 0;
end^

SET TERM ; ^


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 60, column 5.
from.

*/

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 153, column 5.
from.

*/

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 246, column 5.
from.

*/



/*------ SYSDBA 23/07/2013 20:03:59 --------*/

SET TERM ^ ;

create or alter procedure SET_PRODUTO_ROTATIVIDADE (
    DATA date,
    USUARIO varchar(30),
    PRODUTO varchar(10),
    EXCLUIR_ROT smallint,
    TIPO_ROTATI smallint)
as
declare variable TMP_DATA_INI date;
declare variable TMP_DATA_FIM date;
declare variable TMP_COMPRA_QTDE numeric(18,4);
declare variable TMP_COMPRA_VALOR numeric(18,4);
declare variable TMP_VENDA_QTDE numeric(18,4);
declare variable TMP_VENDA_VALOR numeric(18,4);
declare variable UM integer;
declare variable TRES integer;
declare variable SEIS integer;
declare variable NOVE integer;
declare variable DOZE integer;
declare variable NNNN integer;
begin
  um   = 30 * 1;
  tres = 30 * 3;
  seis = 30 * 6;
  nove = 30 * 9;
  doze = 30 * 12;
  nnnn = 30 * 36;

  excluir_rot = coalesce(:excluir_rot, 0);
  tipo_rotati = coalesce(:tipo_rotati, 0); /* 0. Compra | 1. Venda */

  -- Excluir processamento antigo
  if ( :excluir_rot = 1 ) then
    Delete from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto  = :produto;

  /************************************* MES 0-1 *************************************/

  tmp_data_fim = :data;
  tmp_data_ini = :tmp_data_fim - :um;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_01
        , compra_valor_01
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_01
        , venda_valor_01
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_01  = :tmp_compra_qtde
        , rp.compra_valor_01 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_01   = :tmp_venda_qtde
        , rp.venda_valor_01  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 1-3 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :tres;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_03
        , compra_valor_03
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_03
        , venda_valor_03
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_03  = :tmp_compra_qtde
        , rp.compra_valor_03 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_03   = :tmp_venda_qtde
        , rp.venda_valor_03  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 3-6 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :seis;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_06
        , compra_valor_06
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_06
        , venda_valor_06
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_06  = :tmp_compra_qtde
        , rp.compra_valor_06 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_06   = :tmp_venda_qtde
        , rp.venda_valor_06  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 6-9 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :nove;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_09
        , compra_valor_09
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_09
        , venda_valor_09
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_09  = :tmp_compra_qtde
        , rp.compra_valor_09 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_09   = :tmp_venda_qtde
        , rp.venda_valor_09  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 9-12 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :doze;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_12
        , compra_valor_12
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_12
        , venda_valor_12
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_12  = :tmp_compra_qtde
        , rp.compra_valor_12 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_12   = :tmp_venda_qtde
        , rp.venda_valor_12  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 12-nn *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :nnnn;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_99
        , compra_valor_99
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_99
        , venda_valor_99
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_99  = :tmp_compra_qtde
        , rp.compra_valor_99 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_99   = :tmp_venda_qtde
        , rp.venda_valor_99  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

end^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE SET_PRODUTO_ROTATIVIDADE TO "PUBLIC";



/*------ SYSDBA 23/07/2013 20:12:21 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
    ADD DATA_ULTIMA_COMPRA DMN_DATE,
    ADD DATA_ULTIMA_VENDA DMN_DATE;

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.DATA_ULTIMA_COMPRA IS
'Data da ultima compra.';

COMMENT ON COLUMN TBPRODUTO_ROTATIVIDADE.DATA_ULTIMA_VENDA IS
'Data da ultima venda.';




/*------ SYSDBA 23/07/2013 20:14:02 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_PRODUTO_ROTATIVIDADE (
    DATA date,
    USUARIO varchar(30),
    PRODUTO varchar(10),
    EXCLUIR_ROT smallint,
    TIPO_ROTATI smallint,
    ULTIMA_COMPRA date,
    ULTIMA_VENDA date)
as
declare variable TMP_DATA_INI date;
declare variable TMP_DATA_FIM date;
declare variable TMP_COMPRA_QTDE numeric(18,4);
declare variable TMP_COMPRA_VALOR numeric(18,4);
declare variable TMP_VENDA_QTDE numeric(18,4);
declare variable TMP_VENDA_VALOR numeric(18,4);
declare variable UM integer;
declare variable TRES integer;
declare variable SEIS integer;
declare variable NOVE integer;
declare variable DOZE integer;
declare variable NNNN integer;
begin
  um   = 30 * 1;
  tres = 30 * 3;
  seis = 30 * 6;
  nove = 30 * 9;
  doze = 30 * 12;
  nnnn = 30 * 36;

  excluir_rot = coalesce(:excluir_rot, 0);
  tipo_rotati = coalesce(:tipo_rotati, 0); /* 0. Compra | 1. Venda */

  -- Excluir processamento antigo
  if ( :excluir_rot = 1 ) then
    Delete from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto  = :produto;

  /************************************* MES 0-1 *************************************/

  tmp_data_fim = :data;
  tmp_data_ini = :tmp_data_fim - :um;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_01
        , compra_valor_01
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_01
        , venda_valor_01
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_01  = :tmp_compra_qtde
        , rp.compra_valor_01 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_01   = :tmp_venda_qtde
        , rp.venda_valor_01  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 1-3 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :tres;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_03
        , compra_valor_03
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_03
        , venda_valor_03
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_03  = :tmp_compra_qtde
        , rp.compra_valor_03 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_03   = :tmp_venda_qtde
        , rp.venda_valor_03  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 3-6 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :seis;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_06
        , compra_valor_06
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_06
        , venda_valor_06
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_06  = :tmp_compra_qtde
        , rp.compra_valor_06 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_06   = :tmp_venda_qtde
        , rp.venda_valor_06  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 6-9 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :nove;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_09
        , compra_valor_09
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_09
        , venda_valor_09
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_09  = :tmp_compra_qtde
        , rp.compra_valor_09 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_09   = :tmp_venda_qtde
        , rp.venda_valor_09  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 9-12 *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :doze;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_12
        , compra_valor_12
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_12
        , venda_valor_12
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_12  = :tmp_compra_qtde
        , rp.compra_valor_12 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_12   = :tmp_venda_qtde
        , rp.venda_valor_12  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  /************************************* MES 12-nn *************************************/

  tmp_data_fim = :tmp_data_ini - 1;
  tmp_data_ini = :tmp_data_fim - :nnnn;

  Select
      r.compra_qtde
    , r.compra_valor
    , r.venda_qtde
    , r.venda_valor
  from GET_PRODUTO_ROTATIVIDADE(:produto, :tmp_data_ini, :tmp_data_fim) r
  Into
      tmp_compra_qtde
    , tmp_compra_valor
    , tmp_venda_qtde
    , tmp_venda_valor;

  if (not exists(
    Select
      x.cod_produto
    from TBPRODUTO_ROTATIVIDADE x
    where x.cod_produto = :produto
  )) then
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , compra_qtde_99
        , compra_valor_99
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_compra_qtde
        , :tmp_compra_valor
        , current_date
        , current_time
        , :usuario
      );

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Insert Into TBPRODUTO_ROTATIVIDADE (
          cod_produto
        , venda_qtde_99
        , venda_valor_99
        , processo_data
        , processo_hora
        , processo_usuario
      ) values (
          :produto
        , :tmp_venda_qtde
        , :tmp_venda_valor
        , current_date
        , current_time
        , :usuario
      );

    end

  end 
  else
  begin

    if ( :tipo_rotati = 0 ) then -- Compra
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.compra_qtde_99  = :tmp_compra_qtde
        , rp.compra_valor_99 = :tmp_compra_valor
      where rp.cod_produto = :produto;

    end
    else
    if ( :tipo_rotati = 1 ) then -- Venda
    begin

      Update TBPRODUTO_ROTATIVIDADE rp Set
          rp.venda_qtde_99   = :tmp_venda_qtde
        , rp.venda_valor_99  = :tmp_venda_valor
      where rp.cod_produto = :produto;

    end

  end 

  -- Atualizar das Datas de Compra e Venda
  Update TBPRODUTO_ROTATIVIDADE rp Set
      rp.data_ultima_compra = :ultima_compra
    , rp.data_ultima_venda = :ultima_venda
  where rp.cod_produto = :produto;

end^

SET TERM ; ^




/*------ SYSDBA 23/07/2013 21:21:15 --------*/

ALTER TABLE TBPRODUTO_ROTATIVIDADE
ADD CONSTRAINT FK_TBPRODUTO_ROTATIVIDADE
FOREIGN KEY (COD_PRODUTO)
REFERENCES TBPRODUTO(COD);




/*------ SYSDBA 23/07/2013 22:34:27 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_produto_rotatividade_mov for tbproduto_rotatividade
active before insert or update position 0
AS
  declare variable movimento numeric(18,4);
begin
  movimento =
    coalesce(new.compra_qtde_01, 0) + coalesce(new.venda_qtde_01, 0) +
    coalesce(new.compra_qtde_03, 0) + coalesce(new.venda_qtde_03, 0) +
    coalesce(new.compra_qtde_06, 0) + coalesce(new.venda_qtde_06, 0) +
    coalesce(new.compra_qtde_09, 0) + coalesce(new.venda_qtde_09, 0) +
    coalesce(new.compra_qtde_12, 0) + coalesce(new.venda_qtde_12, 0) +
    coalesce(new.compra_qtde_99, 0) + coalesce(new.venda_qtde_99, 0);

  if ( :movimento > 0 ) then
    new.movimentado = 1;
  else
    new.movimentado = 0;

  if ( new.data_ultima_compra = '30.12.1899' ) then
    new.data_ultima_compra = null;
end^

SET TERM ; ^




/*------ SYSDBA 23/07/2013 22:35:08 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_produto_rotatividade_mov for tbproduto_rotatividade
active before insert or update position 0
AS
  declare variable movimento numeric(18,4);
begin
  movimento =
    coalesce(new.compra_qtde_01, 0) + coalesce(new.venda_qtde_01, 0) +
    coalesce(new.compra_qtde_03, 0) + coalesce(new.venda_qtde_03, 0) +
    coalesce(new.compra_qtde_06, 0) + coalesce(new.venda_qtde_06, 0) +
    coalesce(new.compra_qtde_09, 0) + coalesce(new.venda_qtde_09, 0) +
    coalesce(new.compra_qtde_12, 0) + coalesce(new.venda_qtde_12, 0) +
    coalesce(new.compra_qtde_99, 0) + coalesce(new.venda_qtde_99, 0);

  if ( :movimento > 0 ) then
    new.movimentado = 1;
  else
    new.movimentado = 0;

  if ( new.data_ultima_compra = '1899.12.30' ) then
    new.data_ultima_compra = null;
end^

SET TERM ; ^




/*------ SYSDBA 23/07/2013 22:36:09 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_produto_rotatividade_mov for tbproduto_rotatividade
active before insert or update position 0
AS
  declare variable movimento numeric(18,4);
begin
  movimento =
    coalesce(new.compra_qtde_01, 0) + coalesce(new.venda_qtde_01, 0) +
    coalesce(new.compra_qtde_03, 0) + coalesce(new.venda_qtde_03, 0) +
    coalesce(new.compra_qtde_06, 0) + coalesce(new.venda_qtde_06, 0) +
    coalesce(new.compra_qtde_09, 0) + coalesce(new.venda_qtde_09, 0) +
    coalesce(new.compra_qtde_12, 0) + coalesce(new.venda_qtde_12, 0) +
    coalesce(new.compra_qtde_99, 0) + coalesce(new.venda_qtde_99, 0);

  if ( :movimento > 0 ) then
    new.movimentado = 1;
  else
    new.movimentado = 0;

  if ( new.data_ultima_compra = '1899.12.30' ) then
    new.data_ultima_compra = null;

  if ( new.data_ultima_venda = '1899.12.30' ) then
    new.data_ultima_venda = null;
end^

SET TERM ; ^


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Invalid expression in the select list (not contained in either an aggregate function or the GROUP BY clause).

*/

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 11, column 8.
end.

*/



/*------ SYSDBA 05/08/2013 23:54:58 --------*/

CREATE TABLE TBCONFIGURACAO (
    EMPRESA DMN_CNPJ NOT NULL,
    EMAIL_CONTA DMN_VCHAR_100,
    EMAIL_SENHA DMN_VCHAR_100,
    EMAIL_POP DMN_VCHAR_100,
    EMAIL_SMTP DMN_VCHAR_100,
    EMAIL_ASSUNTO_PADRAO DMN_VCHAR_100,
    EMAIL_MENSAGEM_PADRAO DMN_VCHAR_250);

ALTER TABLE TBCONFIGURACAO
ADD CONSTRAINT PK_TBCONFIGURACAO
PRIMARY KEY (EMPRESA);

COMMENT ON COLUMN TBCONFIGURACAO.EMPRESA IS
'Empresa.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_CONTA IS
'E-mail: Conta.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_SENHA IS
'E-mail: Senha.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_POP IS
'E-mail: Servidor POP3.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_SMTP IS
'E-mail: Servidor SMTP.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_ASSUNTO_PADRAO IS
'E-mail: Assunto padrao.';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_MENSAGEM_PADRAO IS
'E-mail: Mensagem padrao.';

GRANT ALL ON TBCONFIGURACAO TO "PUBLIC";



/*------ SYSDBA 05/08/2013 23:55:29 --------*/

ALTER TABLE TBCONFIGURACAO
ADD CONSTRAINT FK_TBCONFIGURACAO_EMPRESA
FOREIGN KEY (EMPRESA)
REFERENCES TBEMPRESA(CNPJ)
ON DELETE CASCADE
ON UPDATE CASCADE;


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 12, column 100.
(.

*/



/*------ SYSDBA 14/08/2013 17:42:09 --------*/

CREATE TABLE TBLOG_TRANSACAO (
    USUARIO DMN_VCHAR_50 NOT NULL,
    DATA_HORA DMN_DATETIME NOT NULL,
    TIPO DMN_SMALLINT_NN DEFAULT 0,
    DESCRICAO DMN_VCHAR_100,
    ESPECIFICACAO DMN_TEXTO);

ALTER TABLE TBLOG_TRANSACAO
ADD CONSTRAINT PK_TBLOG_TRANSACAO
PRIMARY KEY (USUARIO,DATA_HORA);

COMMENT ON COLUMN TBLOG_TRANSACAO.USUARIO IS
'Usuario.';

COMMENT ON COLUMN TBLOG_TRANSACAO.DATA_HORA IS
'Data/hora.';

COMMENT ON COLUMN TBLOG_TRANSACAO.TIPO IS
'Tipo de LOG:
0 - Indefinido
1 - Transacao SEFA
2 - Sistema';

COMMENT ON COLUMN TBLOG_TRANSACAO.DESCRICAO IS
'Descricao.';

COMMENT ON COLUMN TBLOG_TRANSACAO.ESPECIFICACAO IS
'Texto especifico.';

GRANT ALL ON TBLOG_TRANSACAO TO "PUBLIC";

/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 7, column 30.
is.

*/



/*------ SYSDBA 14/08/2013 19:22:22 --------*/

CREATE DOMAIN DMN_VCHAR_18_KEY AS
VARCHAR(10)
NOT NULL;


/*------ SYSDBA 14/08/2013 19:23:09 --------*/

ALTER DOMAIN DMN_VCHAR_18_KEY
TYPE VARCHAR(18) CHARACTER SET ISO8859_2;

CREATE DOMAIN DMN_VCHAR_18_N AS
VARCHAR(18);


/*------ SYSDBA 14/08/2013 19:23:21 --------*/

ALTER TABLE TBNFE_ENVIADA
    ADD EMPRESA DMN_VCHAR_18_N;




/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column EMPRESA position 1;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column SERIE position 2;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column NUMERO position 3;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column ANOVENDA position 4;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column NUMVENDA position 5;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column ANOCOMPRA position 6;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column NUMCOMPRA position 7;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column DATAEMISSAO position 8;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column HORAEMISSAO position 9;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column CHAVE position 10;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column PROTOCOLO position 11;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column RECIBO position 12;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column XML_FILENAME position 13;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column XML_FILE position 14;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column LOTE_ANO position 15;


/*------ SYSDBA 14/08/2013 19:23:33 --------*/

alter table TBNFE_ENVIADA
alter column LOTE_NUM position 16;


/*------ SYSDBA 14/08/2013 19:24:00 --------*/

COMMENT ON COLUMN TBNFE_ENVIADA.EMPRESA IS
'Empresa.';




/*------ SYSDBA 14/08/2013 19:27:30 --------*/

SET TERM ^ ;

CREATE trigger tg_nfe_enviada_empresa for tbnfe_enviada
active before insert or update position 10
AS
begin
  if (new.empresa is null) then
  begin
    /* Identificando a Empresa da Venda (Saida) */
    if (new.anovenda is not null) then
    begin
      Select
        v.codemp
      from TBVENDAS v
      where v.ano        = new.anovenda
        and v.codcontrol = new.numvenda
      Into
        new.empresa;

    end
    else
    /* Identificando a Empresa da Compra (Entrada) */
    if (new.anovenda is not null) then
    begin

      Select
        v.codemp
      from TBVENDAS v
      where v.ano        = new.anovenda
        and v.codcontrol = new.numvenda
      Into
        new.empresa;

    end
  end
end^

SET TERM ; ^




/*------ SYSDBA 14/08/2013 19:28:07 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_enviada_empresa for tbnfe_enviada
active before insert or update position 10
AS
begin
  if (new.empresa is null) then
  begin

    /* Identificando a Empresa da Venda (Saida) */

    if (new.anovenda is not null) then
    begin
      Select
        v.codemp
      from TBVENDAS v
      where v.ano        = new.anovenda
        and v.codcontrol = new.numvenda
      Into
        new.empresa;

    end

    else

    /* Identificando a Empresa da Compra (Entrada) */

    if (new.anovenda is not null) then
    begin

      Select
        v.codemp
      from TBVENDAS v
      where v.ano        = new.anovenda
        and v.codcontrol = new.numvenda
      Into
        new.empresa;

    end

  end
end^

SET TERM ; ^


/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
V.NFE.
At line 19, column 9.

*/



/*------ SYSDBA 14/08/2013 21:59:34 --------*/

COMMENT ON COLUMN TBLOG_TRANSACAO.TIPO IS
'Tipo de LOG:
0 - Notificacoes de uso do sistema
1 - Transacao SEFA
2 - Sistema';




/*------ SYSDBA 15/08/2013 10:51:46 --------*/

ALTER TABLE TBCONFIGURACAO
    ADD EMAIL_SMTP_PORTA DMN_INTEGER_N DEFAULT 25;

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_SMTP_PORTA IS
'E-mail: Porta SMTP.';

alter table TBCONFIGURACAO
alter EMPRESA position 1;

alter table TBCONFIGURACAO
alter EMAIL_CONTA position 2;

alter table TBCONFIGURACAO
alter EMAIL_SENHA position 3;

alter table TBCONFIGURACAO
alter EMAIL_POP position 4;

alter table TBCONFIGURACAO
alter EMAIL_SMTP position 5;

alter table TBCONFIGURACAO
alter EMAIL_SMTP_PORTA position 6;

alter table TBCONFIGURACAO
alter EMAIL_ASSUNTO_PADRAO position 7;

alter table TBCONFIGURACAO
alter EMAIL_MENSAGEM_PADRAO position 8;




/*------ SYSDBA 15/08/2013 10:53:52 --------*/

ALTER TABLE TBCONFIGURACAO
    ADD EMAIL_REQUER_AUTENTICACAO DMN_LOGICO DEFAULT 1,
    ADD EMAIL_CONEXAO_SSL DMN_LOGICO DEFAULT 0;

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_REQUER_AUTENTICACAO IS
'E-mail: Servidor requer autenticacao:
0 - Nao
1 - Sim';

COMMENT ON COLUMN TBCONFIGURACAO.EMAIL_CONEXAO_SSL IS
'E-mail: Conexao Segura (SSL):
0 - Nao
1 - Sim';

alter table TBCONFIGURACAO
alter EMPRESA position 1;

alter table TBCONFIGURACAO
alter EMAIL_CONTA position 2;

alter table TBCONFIGURACAO
alter EMAIL_SENHA position 3;

alter table TBCONFIGURACAO
alter EMAIL_POP position 4;

alter table TBCONFIGURACAO
alter EMAIL_SMTP position 5;

alter table TBCONFIGURACAO
alter EMAIL_SMTP_PORTA position 6;

alter table TBCONFIGURACAO
alter EMAIL_REQUER_AUTENTICACAO position 7;

alter table TBCONFIGURACAO
alter EMAIL_CONEXAO_SSL position 8;

alter table TBCONFIGURACAO
alter EMAIL_ASSUNTO_PADRAO position 9;

alter table TBCONFIGURACAO
alter EMAIL_MENSAGEM_PADRAO position 10;


/*!!! Error occured !!!
Invalid token.
Dynamic SQL Error.
SQL error code = -104.
Token unknown - line 8, column 42.
as.

*/



/*------ SYSDBA 23/08/2013 09:54:48 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_venda for tbnfe_enviada
active after insert position 0
AS
begin
  if ( (new.anovenda > 0) and (new.numvenda > 0) ) then
  begin
    Update TBVENDAS v Set
        v.serie = new.serie
      , v.nfe   = new.numero
      , v.nfe_enviada      = 1
      , v.verificador_nfe  = new.chave
      , v.xml_nfe_filename = new.xml_filename
      , v.xml_nfe          = new.xml_file
      , v.status      = 4 -- Nota Fiscal Gerada
      , v.dataemissao = new.dataemissao
      , v.horaemissao = new.horaemissao
    where v.ano = new.anovenda
      and v.codcontrol = new.numvenda;
  end 
end^

SET TERM ; ^




/*------ SYSDBA 23/08/2013 09:55:08 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_compra for tbnfe_enviada
active after insert position 1
AS
begin
  if ( (new.anocompra > 0) and (new.numcompra > 0) ) then
  begin
    Update TBCOMPRAS c Set
        c.nfserie = new.serie
      , c.nf      = new.numero
      , c.nfe_enviada      = 1
      , c.verificador_nfe  = new.chave
      , c.xml_nfe_filename = new.xml_filename
      , c.xml_nfe          = new.xml_file
      , c.status  = 4 -- Nota Fiscal Gerada
      , c.dtemiss = new.dataemissao
      , c.hremiss = new.horaemissao
    where c.ano        = new.anocompra
      and c.codcontrol = new.numcompra;
  end 
end^

SET TERM ; ^




/*------ SYSDBA 23/08/2013 09:57:13 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_compra for tbnfe_enviada
active after insert position 1
AS
begin
  if ( (new.anocompra > 0) and (new.numcompra > 0) ) then
  begin
    Update TBCOMPRAS c Set
        c.nfserie = new.serie
      , c.nf      = new.numero
      , c.nfe_enviada      = 1
      , c.verificador_nfe  = new.chave
      , c.xml_nfe_filename = new.xml_filename
      , c.xml_nfe          = new.xml_file
      , c.lote_nfe_ano     = new.lote_ano
      , c.lote_nfe_numero  = new.lote_num
      , c.status  = 4 -- Nota Fiscal Gerada
      , c.dtemiss = new.dataemissao
      , c.hremiss = new.horaemissao
    where c.ano        = new.anocompra
      and c.codcontrol = new.numcompra;
  end 
end^

SET TERM ; ^




/*------ SYSDBA 23/08/2013 09:57:30 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_venda for tbnfe_enviada
active after insert position 0
AS
begin
  if ( (new.anovenda > 0) and (new.numvenda > 0) ) then
  begin
    Update TBVENDAS v Set
        v.serie = new.serie
      , v.nfe   = new.numero
      , v.nfe_enviada      = 1
      , v.verificador_nfe  = new.chave
      , v.xml_nfe_filename = new.xml_filename
      , v.xml_nfe          = new.xml_file
      , v.lote_nfe_ano     = new.lote_ano
      , v.lote_nfe_numero  = new.lote_num
      , v.status      = 4 -- Nota Fiscal Gerada
      , v.dataemissao = new.dataemissao
      , v.horaemissao = new.horaemissao
    where v.ano = new.anovenda
      and v.codcontrol = new.numvenda;
  end 
end^

SET TERM ; ^


/*!!! Error occured !!!
Column does not belong to referenced table.
Dynamic SQL Error.
SQL error code = -206.
Column unknown.
C.NFE.
At line 24, column 9.

*/



/*------ SYSDBA 23/08/2013 11:27:06 --------*/

ALTER TABLE TBVENDAS
    ADD LOTE_NFE_RECIBO DMN_VCHAR_250;

COMMENT ON COLUMN TBVENDAS.LOTE_NFE_RECIBO IS
'Numero do recibo de envio da NFe.';

alter table TBVENDAS
alter ANO position 1;

alter table TBVENDAS
alter CODCONTROL position 2;

alter table TBVENDAS
alter CODEMP position 3;

alter table TBVENDAS
alter CODCLI position 4;

alter table TBVENDAS
alter DTVENDA position 5;

alter table TBVENDAS
alter STATUS position 6;

alter table TBVENDAS
alter TOTALVENDA_BRUTA position 7;

alter table TBVENDAS
alter DESCONTO position 8;

alter table TBVENDAS
alter TOTALVENDA position 9;

alter table TBVENDAS
alter TOTALCUSTO position 10;

alter table TBVENDAS
alter DTFINALIZACAO_VENDA position 11;

alter table TBVENDAS
alter OBS position 12;

alter table TBVENDAS
alter FORMAPAG position 13;

alter table TBVENDAS
alter FATDIAS position 14;

alter table TBVENDAS
alter SERIE position 15;

alter table TBVENDAS
alter NFE position 16;

alter table TBVENDAS
alter DATAEMISSAO position 17;

alter table TBVENDAS
alter HORAEMISSAO position 18;

alter table TBVENDAS
alter CFOP position 19;

alter table TBVENDAS
alter VERIFICADOR_NFE position 20;

alter table TBVENDAS
alter XML_NFE position 21;

alter table TBVENDAS
alter VENDEDOR_COD position 22;

alter table TBVENDAS
alter USUARIO position 23;

alter table TBVENDAS
alter FORMAPAGTO_COD position 24;

alter table TBVENDAS
alter CONDICAOPAGTO_COD position 25;

alter table TBVENDAS
alter VENDA_PRAZO position 26;

alter table TBVENDAS
alter PRAZO_01 position 27;

alter table TBVENDAS
alter PRAZO_02 position 28;

alter table TBVENDAS
alter PRAZO_03 position 29;

alter table TBVENDAS
alter PRAZO_04 position 30;

alter table TBVENDAS
alter PRAZO_05 position 31;

alter table TBVENDAS
alter PRAZO_06 position 32;

alter table TBVENDAS
alter PRAZO_07 position 33;

alter table TBVENDAS
alter PRAZO_08 position 34;

alter table TBVENDAS
alter PRAZO_09 position 35;

alter table TBVENDAS
alter PRAZO_10 position 36;

alter table TBVENDAS
alter PRAZO_11 position 37;

alter table TBVENDAS
alter PRAZO_12 position 38;

alter table TBVENDAS
alter LOTE_NFE_ANO position 39;

alter table TBVENDAS
alter LOTE_NFE_NUMERO position 40;

alter table TBVENDAS
alter LOTE_NFE_RECIBO position 41;

alter table TBVENDAS
alter NFE_ENVIADA position 42;

alter table TBVENDAS
alter CANCEL_USUARIO position 43;

alter table TBVENDAS
alter CANCEL_DATAHORA position 44;

alter table TBVENDAS
alter CANCEL_MOTIVO position 45;

alter table TBVENDAS
alter XML_NFE_FILENAME position 46;

alter table TBVENDAS
alter NFE_MODALIDADE_FRETE position 47;

alter table TBVENDAS
alter NFE_TRANSPORTADORA position 48;

alter table TBVENDAS
alter NFE_PLACA_VEICULO position 49;

alter table TBVENDAS
alter NFE_PLACA_UF position 50;

alter table TBVENDAS
alter NFE_PLACA_RNTC position 51;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS position 52;

alter table TBVENDAS
alter NFE_VALOR_ICMS position 53;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS_SUBST position 54;

alter table TBVENDAS
alter NFE_VALOR_ICMS_SUBST position 55;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_PRODUTO position 56;

alter table TBVENDAS
alter NFE_VALOR_FRETE position 57;

alter table TBVENDAS
alter NFE_VALOR_SEGURO position 58;

alter table TBVENDAS
alter NFE_VALOR_DESCONTO position 59;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_II position 60;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_IPI position 61;

alter table TBVENDAS
alter NFE_VALOR_PIS position 62;

alter table TBVENDAS
alter NFE_VALOR_COFINS position 63;

alter table TBVENDAS
alter NFE_VALOR_OUTROS position 64;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_NOTA position 65;




/*------ SYSDBA 23/08/2013 11:27:45 --------*/

ALTER TABLE TBCOMPRAS
    ADD LOTE_NFE_RECIBO DMN_VCHAR_250;

COMMENT ON COLUMN TBCOMPRAS.LOTE_NFE_RECIBO IS
'Numero do recibo de envio da NFe.';

alter table TBCOMPRAS
alter ANO position 1;

alter table TBCOMPRAS
alter CODCONTROL position 2;

alter table TBCOMPRAS
alter CODEMP position 3;

alter table TBCOMPRAS
alter CODFORN position 4;

alter table TBCOMPRAS
alter NF position 5;

alter table TBCOMPRAS
alter NFSERIE position 6;

alter table TBCOMPRAS
alter LOTE_NFE_ANO position 7;

alter table TBCOMPRAS
alter LOTE_NFE_NUMERO position 8;

alter table TBCOMPRAS
alter LOTE_NFE_RECIBO position 9;

alter table TBCOMPRAS
alter NFE_ENVIADA position 10;

alter table TBCOMPRAS
alter VERIFICADOR_NFE position 11;

alter table TBCOMPRAS
alter XML_NFE position 12;

alter table TBCOMPRAS
alter XML_NFE_FILENAME position 13;

alter table TBCOMPRAS
alter DTLANCAMENTO position 14;

alter table TBCOMPRAS
alter DTEMISS position 15;

alter table TBCOMPRAS
alter HREMISS position 16;

alter table TBCOMPRAS
alter DTENT position 17;

alter table TBCOMPRAS
alter NFCFOP position 18;

alter table TBCOMPRAS
alter NATUREZA position 19;

alter table TBCOMPRAS
alter STATUS position 20;

alter table TBCOMPRAS
alter IPI position 21;

alter table TBCOMPRAS
alter ICMSBASE position 22;

alter table TBCOMPRAS
alter ICMSVALOR position 23;

alter table TBCOMPRAS
alter ICMSSUBSTBASE position 24;

alter table TBCOMPRAS
alter ICMSSUBSTVALOR position 25;

alter table TBCOMPRAS
alter FRETE position 26;

alter table TBCOMPRAS
alter OUTROSCUSTOS position 27;

alter table TBCOMPRAS
alter DESCONTO position 28;

alter table TBCOMPRAS
alter VALORSEGURO position 29;

alter table TBCOMPRAS
alter VALORTOTAL_II position 30;

alter table TBCOMPRAS
alter VALORTOTAL_IPI position 31;

alter table TBCOMPRAS
alter VALORPIS position 32;

alter table TBCOMPRAS
alter VALORCOFINS position 33;

alter table TBCOMPRAS
alter TOTALPROD position 34;

alter table TBCOMPRAS
alter TOTALNF position 35;

alter table TBCOMPRAS
alter OBS position 36;

alter table TBCOMPRAS
alter USUARIO position 37;

alter table TBCOMPRAS
alter FORMAPAGTO_COD position 38;

alter table TBCOMPRAS
alter CONDICAOPAGTO_COD position 39;

alter table TBCOMPRAS
alter COMPRA_PRAZO position 40;

alter table TBCOMPRAS
alter PRAZO_01 position 41;

alter table TBCOMPRAS
alter PRAZO_02 position 42;

alter table TBCOMPRAS
alter PRAZO_03 position 43;

alter table TBCOMPRAS
alter PRAZO_04 position 44;

alter table TBCOMPRAS
alter PRAZO_05 position 45;

alter table TBCOMPRAS
alter PRAZO_06 position 46;

alter table TBCOMPRAS
alter PRAZO_07 position 47;

alter table TBCOMPRAS
alter PRAZO_08 position 48;

alter table TBCOMPRAS
alter PRAZO_09 position 49;

alter table TBCOMPRAS
alter PRAZO_10 position 50;

alter table TBCOMPRAS
alter PRAZO_11 position 51;

alter table TBCOMPRAS
alter PRAZO_12 position 52;

alter table TBCOMPRAS
alter DTFINALIZACAO_COMPRA position 53;

alter table TBCOMPRAS
alter CANCEL_USUARIO position 54;

alter table TBCOMPRAS
alter CANCEL_DATAHORA position 55;

alter table TBCOMPRAS
alter CANCEL_MOTIVO position 56;




/*------ SYSDBA 23/08/2013 11:28:13 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_venda for tbnfe_enviada
active after insert position 0
AS
begin
  if ( (new.anovenda > 0) and (new.numvenda > 0) ) then
  begin
    Update TBVENDAS v Set
        v.serie = new.serie
      , v.nfe   = new.numero
      , v.nfe_enviada      = 1
      , v.verificador_nfe  = new.chave
      , v.xml_nfe_filename = new.xml_filename
      , v.xml_nfe          = new.xml_file
      , v.lote_nfe_ano     = new.lote_ano
      , v.lote_nfe_numero  = new.lote_num
      , v.lote_nfe_recibo  = new.recibo
      , v.status      = 4 -- Nota Fiscal Gerada
      , v.dataemissao = new.dataemissao
      , v.horaemissao = new.horaemissao
    where v.ano = new.anovenda
      and v.codcontrol = new.numvenda;
  end 
end^

SET TERM ; ^




/*------ SYSDBA 23/08/2013 11:28:45 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_nfe_atualizar_compra for tbnfe_enviada
active after insert position 1
AS
begin
  if ( (new.anocompra > 0) and (new.numcompra > 0) ) then
  begin
    Update TBCOMPRAS c Set
        c.nfserie = new.serie
      , c.nf      = new.numero
      , c.nfe_enviada      = 1
      , c.verificador_nfe  = new.chave
      , c.xml_nfe_filename = new.xml_filename
      , c.xml_nfe          = new.xml_file
      , c.lote_nfe_ano     = new.lote_ano
      , c.lote_nfe_numero  = new.lote_num
      , c.lote_nfe_recibo  = new.recibo
      , c.status  = 4 -- Nota Fiscal Gerada
      , c.dtemiss = new.dataemissao
      , c.hremiss = new.horaemissao
    where c.ano        = new.anocompra
      and c.codcontrol = new.numcompra;
  end 
end^

SET TERM ; ^




/*------ SYSDBA 23/08/2013 13:12:42 --------*/

COMMENT ON COLUMN TBVENDAS.NFE_ENVIADA IS
'NF de Saida Enviada:
0 - Nao
1 - Sim';




/*------ SYSDBA 23/08/2013 13:12:50 --------*/

ALTER TABLE TBVENDAS ADD IBE$$TEMP_COLUMN
 SMALLINT DEFAULT 0
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBVENDAS') AND
      (F1.RDB$FIELD_NAME = 'NFE_ENVIADA');

ALTER TABLE TBVENDAS DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 23/08/2013 13:13:18 --------*/

COMMENT ON COLUMN TBCOMPRAS.LOTE_NFE_ANO IS
'Ano do lote de envio (Interno).';




/*------ SYSDBA 23/08/2013 13:13:29 --------*/

COMMENT ON COLUMN TBCOMPRAS.LOTE_NFE_NUMERO IS
'Numero do lote de envio (Interno).';




/*------ SYSDBA 23/08/2013 13:13:42 --------*/

COMMENT ON COLUMN TBCOMPRAS.LOTE_NFE_RECIBO IS
'Numero do recibo de solicitacao de envio da NFe.';




/*------ SYSDBA 23/08/2013 13:13:58 --------*/

COMMENT ON COLUMN TBVENDAS.LOTE_NFE_ANO IS
'Ano do lote de envio (Interno).';




/*------ SYSDBA 23/08/2013 13:14:06 --------*/

COMMENT ON COLUMN TBVENDAS.LOTE_NFE_NUMERO IS
'Numero do lote de envio (Interno).';




/*------ SYSDBA 23/08/2013 13:14:13 --------*/

COMMENT ON COLUMN TBVENDAS.LOTE_NFE_RECIBO IS
'Numero do recibo de solicitacao de envio da NFe.';




/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column EMPRESA position 1;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column SERIE position 2;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column NUMERO position 3;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column ANOVENDA position 4;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column NUMVENDA position 5;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column ANOCOMPRA position 6;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column NUMCOMPRA position 7;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column DATAEMISSAO position 8;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column HORAEMISSAO position 9;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column CHAVE position 10;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column PROTOCOLO position 11;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column RECIBO position 12;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column XML_FILENAME position 13;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column XML_FILE position 14;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column LOTE_ANO position 15;


/*------ SYSDBA 30/08/2013 10:58:51 --------*/

alter table TBNFE_ENVIADA
alter column LOTE_NUM position 16;


/*------ SYSDBA 03/09/2013 16:06:14 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD EMPRESA DMN_CNPJ;

COMMENT ON COLUMN TBBANCO_BOLETO.EMPRESA IS
'Empresa.';




/*------ SYSDBA 03/09/2013 16:06:42 --------*/

ALTER TABLE TBBANCO_BOLETO
ADD CONSTRAINT FK_TBBANCO_BOLETO_EMPRESA
FOREIGN KEY (EMPRESA)
REFERENCES TBEMPRESA(CNPJ);




/*------ SYSDBA 03/09/2013 16:09:14 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD BCO_GERAR_BOLETO DMN_SMALLINT_N DEFAULT 0;

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_GERAR_BOLETO IS
'Gerar Boleto:
0 - Nao
1 - Sim';




/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_COD position 1;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CARTEIRA position 2;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOME position 3;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CHAVE position 4;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_AGENCIA position 5;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CC position 6;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_GERAR_BOLETO position 7;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_INICIO position 8;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_FINAL position 9;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_PROXIMO position 10;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_1 position 11;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_2 position 12;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_SEQUENCIAL_REM position 13;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_REMESSA position 14;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_RETORNO position 15;


/*------ SYSDBA 03/09/2013 16:09:38 --------*/

alter table TBBANCO_BOLETO
alter column EMPRESA position 16;


/*------ SYSDBA 03/09/2013 18:06:21 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD BCO_NUMERO_CONTRATO DMN_VCHAR_10;

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_NUMERO_CONTRATO IS
'Numero do Convenio/Contrato.';

alter table TBBANCO_BOLETO
alter BCO_COD position 1;

alter table TBBANCO_BOLETO
alter BCO_CARTEIRA position 2;

alter table TBBANCO_BOLETO
alter BCO_NOME position 3;

alter table TBBANCO_BOLETO
alter BCO_CHAVE position 4;

alter table TBBANCO_BOLETO
alter BCO_AGENCIA position 5;

alter table TBBANCO_BOLETO
alter BCO_CC position 6;

alter table TBBANCO_BOLETO
alter BCO_GERAR_BOLETO position 7;

alter table TBBANCO_BOLETO
alter BCO_NUMERO_CONTRATO position 8;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_INICIO position 9;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_FINAL position 10;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_PROXIMO position 11;

alter table TBBANCO_BOLETO
alter BCO_CONFG_1 position 12;

alter table TBBANCO_BOLETO
alter BCO_CONFG_2 position 13;

alter table TBBANCO_BOLETO
alter BCO_SEQUENCIAL_REM position 14;

alter table TBBANCO_BOLETO
alter BCO_DIRETORIO_REMESSA position 15;

alter table TBBANCO_BOLETO
alter BCO_DIRETORIO_RETORNO position 16;

alter table TBBANCO_BOLETO
alter EMPRESA position 17;




/*------ SYSDBA 03/09/2013 18:06:53 --------*/

ALTER TABLE TBBANCO_BOLETO DROP BCO_NUMERO_CONTRATO;




/*------ SYSDBA 03/09/2013 18:07:08 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_CHAVE IS
'Numero do Convenio/Contrato.';




/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_COD position 1;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column EMPRESA position 2;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CARTEIRA position 3;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOME position 4;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CHAVE position 5;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_AGENCIA position 6;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CC position 7;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_GERAR_BOLETO position 8;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_INICIO position 9;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_FINAL position 10;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_PROXIMO position 11;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_1 position 12;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_2 position 13;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_SEQUENCIAL_REM position 14;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_REMESSA position 15;


/*------ SYSDBA 03/09/2013 18:57:24 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_RETORNO position 16;


/*------ SYSDBA 03/09/2013 20:13:49 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD BCO_CODIGO_CEDENTE DMN_VCHAR_10;

alter table TBBANCO_BOLETO
alter BCO_COD position 1;

alter table TBBANCO_BOLETO
alter EMPRESA position 2;

alter table TBBANCO_BOLETO
alter BCO_CARTEIRA position 3;

alter table TBBANCO_BOLETO
alter BCO_NOME position 4;

alter table TBBANCO_BOLETO
alter BCO_CODIGO_CEDENTE position 5;

alter table TBBANCO_BOLETO
alter BCO_CHAVE position 6;

alter table TBBANCO_BOLETO
alter BCO_AGENCIA position 7;

alter table TBBANCO_BOLETO
alter BCO_CC position 8;

alter table TBBANCO_BOLETO
alter BCO_GERAR_BOLETO position 9;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_INICIO position 10;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_FINAL position 11;

alter table TBBANCO_BOLETO
alter BCO_NOSSO_NUM_PROXIMO position 12;

alter table TBBANCO_BOLETO
alter BCO_CONFG_1 position 13;

alter table TBBANCO_BOLETO
alter BCO_CONFG_2 position 14;

alter table TBBANCO_BOLETO
alter BCO_SEQUENCIAL_REM position 15;

alter table TBBANCO_BOLETO
alter BCO_DIRETORIO_REMESSA position 16;

alter table TBBANCO_BOLETO
alter BCO_DIRETORIO_RETORNO position 17;




/*------ SYSDBA 03/09/2013 20:14:12 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_CODIGO_CEDENTE IS
'Codigo do Cedente.';




/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_COD position 1;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column EMPRESA position 2;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CARTEIRA position 3;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOME position 4;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_AGENCIA position 5;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CC position 6;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CODIGO_CEDENTE position 7;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CHAVE position 8;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_GERAR_BOLETO position 9;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_INICIO position 10;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_FINAL position 11;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_NOSSO_NUM_PROXIMO position 12;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_1 position 13;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_CONFG_2 position 14;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_SEQUENCIAL_REM position 15;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_REMESSA position 16;


/*------ SYSDBA 03/09/2013 20:14:32 --------*/

alter table TBBANCO_BOLETO
alter column BCO_DIRETORIO_RETORNO position 17;


/*------ SYSDBA 12/09/2013 14:08:42 --------*/

ALTER TABLE TBCONFIGURACAO
    ADD NFE_SOLICITA_DH_SAIDA DMN_LOGICO DEFAULT 0;

COMMENT ON COLUMN TBCONFIGURACAO.NFE_SOLICITA_DH_SAIDA IS
'NF-e: Solicitar Data/Hora de saida:
0 - Nao
1 - Sim';




/*------ SYSDBA 12/09/2013 14:09:08 --------*/

ALTER TABLE TBCONFIGURACAO ADD IBE$$TEMP_COLUMN
 INTEGER DEFAULT 587
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
      (F1.RDB$FIELD_NAME = 'EMAIL_SMTP_PORTA');

ALTER TABLE TBCONFIGURACAO DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 13/09/2013 00:16:27 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD BCO_PERCENTUAL_JUROS DMN_PERCENTUAL DEFAULT 0,
    ADD BCO_PERCENTUAL_MORA DMN_PERCENTUAL DEFAULT 0,
    ADD BCO_DIA_PROTESTO DMN_SMALLINT_N DEFAULT 0,
    ADD BCO_MSG_INSTRUCAO DMN_VCHAR_250;

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_JUROS IS
'Juros - Percentual de 0 a 100.';

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_MORA IS
'Mora - Percentual de 0 a 100.';

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_DIA_PROTESTO IS
'Dias para protesto apos o vencimento.';

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_MSG_INSTRUCAO IS
'Mensagem de instrucao ao Caixa do banco.';




/*------ SYSDBA 13/09/2013 00:43:41 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_MORA IS
'Mora de Juros - Percentual de 0 a 100.';




/*------ SYSDBA 13/09/2013 00:44:13 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_JUROS IS
'Percentual de juros por dia de atraso.';




/*------ SYSDBA 13/09/2013 00:51:42 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_MORA IS
'Percentual de multa (mora) por atraso.';




/*------ SYSDBA 13/09/2013 08:44:18 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_MORA IS
'Percentual de Mora Mes por atraso.';




/*------ SYSDBA 13/09/2013 08:44:32 --------*/

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_PERCENTUAL_JUROS IS
'Percentual de multa por dia de atraso.';




/*------ SYSDBA 13/09/2013 08:45:45 --------*/

COMMENT ON COLUMN TBCONTREC.PERCENTJUROS IS
'Percentual de multa por dia de atraso.';




/*------ SYSDBA 13/09/2013 08:45:49 --------*/

COMMENT ON COLUMN TBCONTREC.PERCENTMULTA IS
'Percentual de Mora Mes por atraso.';




/*------ SYSDBA 13/09/2013 15:30:20 --------*/

ALTER TABLE TBCONFIGURACAO
    ADD NFE_IMPRIMIR_COD_CLIENTE DMN_LOGICO;

COMMENT ON COLUMN TBCONFIGURACAO.NFE_IMPRIMIR_COD_CLIENTE IS
'NF-e: Imprimir codigo interno do cliente na NF-e:
0 - Nao
1 - Sim';




/*------ SYSDBA 13/09/2013 15:30:24 --------*/

UPDATE TBCONFIGURACAO
SET NFE_IMPRIMIR_COD_CLIENTE = 0;




/*------ SYSDBA 13/09/2013 15:30:33 --------*/

ALTER TABLE TBCONFIGURACAO ADD IBE$$TEMP_COLUMN
 SMALLINT DEFAULT 0
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBCONFIGURACAO') AND
      (F1.RDB$FIELD_NAME = 'NFE_IMPRIMIR_COD_CLIENTE');

ALTER TABLE TBCONFIGURACAO DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 13/09/2013 16:08:43 --------*/

ALTER TABLE TVENDASITENS
    ADD CST DMN_VCHAR_03,
    ADD CSOSN DMN_VCHAR_03;

alter table TVENDASITENS
alter ANO position 1;

alter table TVENDASITENS
alter CODCONTROL position 2;

alter table TVENDASITENS
alter SEQ position 3;

alter table TVENDASITENS
alter CODPROD position 4;

alter table TVENDASITENS
alter CODEMP position 5;

alter table TVENDASITENS
alter CODCLI position 6;

alter table TVENDASITENS
alter DTVENDA position 7;

alter table TVENDASITENS
alter QTDE position 8;

alter table TVENDASITENS
alter PUNIT position 9;

alter table TVENDASITENS
alter PUNIT_PROMOCAO position 10;

alter table TVENDASITENS
alter DESCONTO position 11;

alter table TVENDASITENS
alter DESCONTO_VALOR position 12;

alter table TVENDASITENS
alter PFINAL position 13;

alter table TVENDASITENS
alter QTDEFINAL position 14;

alter table TVENDASITENS
alter UNID_COD position 15;

alter table TVENDASITENS
alter CFOP_COD position 16;

alter table TVENDASITENS
alter CST position 17;

alter table TVENDASITENS
alter CSOSN position 18;

alter table TVENDASITENS
alter ALIQUOTA position 19;

alter table TVENDASITENS
alter ALIQUOTA_CSOSN position 20;

alter table TVENDASITENS
alter ALIQUOTA_PIS position 21;

alter table TVENDASITENS
alter ALIQUOTA_COFINS position 22;

alter table TVENDASITENS
alter VALOR_IPI position 23;

alter table TVENDASITENS
alter PERCENTUAL_REDUCAO_BC position 24;

alter table TVENDASITENS
alter TOTAL_BRUTO position 25;

alter table TVENDASITENS
alter TOTAL_DESCONTO position 26;

alter table TVENDASITENS
alter TOTAL_LIQUIDO position 27;




/*------ SYSDBA 14/09/2013 11:12:02 --------*/

ALTER TABLE TBBANCO_BOLETO
    ADD BCO_LAYOUT_REMESSA DMN_SMALLINT_N,
    ADD BCO_LAYOUT_RETORNO DMN_SMALLINT_N;

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_LAYOUT_REMESSA IS
'Layout de Remessa:
240 - CNAB240 
400 - CNAB400';

COMMENT ON COLUMN TBBANCO_BOLETO.BCO_LAYOUT_RETORNO IS
'Layout de Remessa:
240 - CNAB240 
400 - CNAB400';




/*------ SYSDBA 16/09/2013 10:06:52 --------*/

create view vw_layout_rem_ret_banco ( Codigo, Descricao )
as
Select
    240 as Codigo
  , 'cnab240' as Descricao
from RDB$DATABASE

union

Select
    400 as Codigo
  , 'cnab400' as Descricao
from RDB$DATABASE
;




/*------ SYSDBA 16/09/2013 23:13:50 --------*/

ALTER TABLE TBPRODUTO
    ADD PESO_BRUTO DMN_MONEY_DESCONTO,
    ADD PESO_LIQUIDO DMN_MONEY_DESCONTO,
    ADD CUBAGEM DMN_MONEY_DESCONTO;

COMMENT ON COLUMN TBPRODUTO.PESO_BRUTO IS
'Peso bruto (Kg).';

COMMENT ON COLUMN TBPRODUTO.PESO_LIQUIDO IS
'Peso liquido (Kg).';

COMMENT ON COLUMN TBPRODUTO.CUBAGEM IS
'Cubagem (m3).';

alter table TBPRODUTO
alter CODIGO position 1;

alter table TBPRODUTO
alter COD position 2;

alter table TBPRODUTO
alter DESCRI position 3;

alter table TBPRODUTO
alter APRESENTACAO position 4;

alter table TBPRODUTO
alter DESCRI_APRESENTACAO position 5;

alter table TBPRODUTO
alter MODELO position 6;

alter table TBPRODUTO
alter PRECO position 7;

alter table TBPRODUTO
alter PRECO_PROMOCAO position 8;

alter table TBPRODUTO
alter REFERENCIA position 9;

alter table TBPRODUTO
alter SECAO position 10;

alter table TBPRODUTO
alter QTDE position 11;

alter table TBPRODUTO
alter FRACIONADOR position 12;

alter table TBPRODUTO
alter PESO_BRUTO position 13;

alter table TBPRODUTO
alter PESO_LIQUIDO position 14;

alter table TBPRODUTO
alter CUBAGEM position 15;

alter table TBPRODUTO
alter VENDA_FRACIONADA position 16;

alter table TBPRODUTO
alter CODUNIDADE_FRACIONADA position 17;

alter table TBPRODUTO
alter UNIDADE position 18;

alter table TBPRODUTO
alter ESTOQMIN position 19;

alter table TBPRODUTO
alter CODGRUPO position 20;

alter table TBPRODUTO
alter CODFABRICANTE position 21;

alter table TBPRODUTO
alter CUSTOMEDIO position 22;

alter table TBPRODUTO
alter PERCENTUAL_MARCKUP position 23;

alter table TBPRODUTO
alter PERCENTUAL_MARGEM position 24;

alter table TBPRODUTO
alter PRECO_SUGERIDO position 25;

alter table TBPRODUTO
alter CODEMP position 26;

alter table TBPRODUTO
alter CODSECAO position 27;

alter table TBPRODUTO
alter CODORIGEM position 28;

alter table TBPRODUTO
alter CODTRIBUTACAO position 29;

alter table TBPRODUTO
alter CST position 30;

alter table TBPRODUTO
alter CSOSN position 31;

alter table TBPRODUTO
alter CST_PIS position 32;

alter table TBPRODUTO
alter CST_COFINS position 33;

alter table TBPRODUTO
alter NCM_SH position 34;

alter table TBPRODUTO
alter CODCFOP position 35;

alter table TBPRODUTO
alter CODBARRA_EAN position 36;

alter table TBPRODUTO
alter CODUNIDADE position 37;

alter table TBPRODUTO
alter ALIQUOTA_TIPO position 38;

alter table TBPRODUTO
alter ALIQUOTA position 39;

alter table TBPRODUTO
alter ALIQUOTA_CSOSN position 40;

alter table TBPRODUTO
alter ALIQUOTA_PIS position 41;

alter table TBPRODUTO
alter ALIQUOTA_COFINS position 42;

alter table TBPRODUTO
alter VALOR_IPI position 43;

alter table TBPRODUTO
alter RESERVA position 44;

alter table TBPRODUTO
alter PRODUTO_NOVO position 45;

alter table TBPRODUTO
alter COR_VEICULO position 46;

alter table TBPRODUTO
alter COMBUSTIVEL_VEICULO position 47;

alter table TBPRODUTO
alter TIPO_VEICULO position 48;

alter table TBPRODUTO
alter ANO_MODELO_VEICULO position 49;

alter table TBPRODUTO
alter ANO_FABRICACAO_VEICULO position 50;

alter table TBPRODUTO
alter RENAVAM_VEICULO position 51;

alter table TBPRODUTO
alter CHASSI_VEICULO position 52;

alter table TBPRODUTO
alter KILOMETRAGEM_VEICULO position 53;

alter table TBPRODUTO
alter SITUACAO_ATUAL_VEICULO position 54;

alter table TBPRODUTO
alter SITUACAO_HISTORICO_VEICULO position 55;

alter table TBPRODUTO
alter PERCENTUAL_REDUCAO_BC position 56;

alter table TBPRODUTO
alter USUARIO position 57;




/*------ SYSDBA 16/09/2013 23:14:54 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_DESCONTO_4'
where (RDB$FIELD_NAME = 'CUBAGEM') and
(RDB$RELATION_NAME = 'TBPRODUTO')
;




/*------ SYSDBA 17/09/2013 00:37:00 --------*/

ALTER TABLE TBCONTREC
    ADD EMPRESA DMN_CNPJ;

COMMENT ON COLUMN TBCONTREC.EMPRESA IS
'Empresa.';

alter table TBCONTREC
alter ANOLANC position 1;

alter table TBCONTREC
alter NUMLANC position 2;

alter table TBCONTREC
alter EMPRESA position 3;

alter table TBCONTREC
alter CNPJ position 4;

alter table TBCONTREC
alter FORMA_PAGTO position 5;

alter table TBCONTREC
alter TIPPAG position 6;

alter table TBCONTREC
alter HISTORIC position 7;

alter table TBCONTREC
alter NUMREC position 8;

alter table TBCONTREC
alter DTEMISS position 9;

alter table TBCONTREC
alter DTVENC position 10;

alter table TBCONTREC
alter DTREC position 11;

alter table TBCONTREC
alter DOCBAIX position 12;

alter table TBCONTREC
alter VALORREC position 13;

alter table TBCONTREC
alter VALORMULTA position 14;

alter table TBCONTREC
alter VALORRECTOT position 15;

alter table TBCONTREC
alter NUMCONTRATO position 16;

alter table TBCONTREC
alter PARCELA position 17;

alter table TBCONTREC
alter STATUS position 18;

alter table TBCONTREC
alter CODBANCO position 19;

alter table TBCONTREC
alter NOSSONUMERO position 20;

alter table TBCONTREC
alter REMESSA position 21;

alter table TBCONTREC
alter VALORSALDO position 22;

alter table TBCONTREC
alter PERCENTJUROS position 23;

alter table TBCONTREC
alter PERCENTMULTA position 24;

alter table TBCONTREC
alter PERCENTDESCONTO position 25;

alter table TBCONTREC
alter DATAPROCESSOBOLETO position 26;

alter table TBCONTREC
alter BAIXADO position 27;

alter table TBCONTREC
alter ENVIADO position 28;

alter table TBCONTREC
alter ANOVENDA position 29;

alter table TBCONTREC
alter NUMVENDA position 30;

alter table TBCONTREC
alter SITUACAO position 31;




/*------ SYSDBA 17/09/2013 00:40:05 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_GERAR_TITULOS (
    ANOVENDA smallint,
    NUMVENDA integer)
returns (
    EMPRESA varchar(18),
    CLIENTE varchar(18),
    PARCELAS smallint,
    VALOR_TOTAL numeric(15,2),
    PARCELA smallint,
    EMISSAO date,
    VENCIMENTO date,
    VALOR_DOCUMENTO numeric(15,2),
    FORMA_PAGTO smallint,
    DATA_FINALIZ_VENDA date,
    ANO_LANC smallint,
    NUM_LANC integer)
as
declare variable P01 smallint;
declare variable P02 smallint;
declare variable P03 smallint;
declare variable P04 smallint;
declare variable P05 smallint;
declare variable P06 smallint;
declare variable P07 smallint;
declare variable P08 smallint;
declare variable P09 smallint;
declare variable P10 smallint;
declare variable P11 smallint;
declare variable P12 smallint;
declare variable VALOR_TOTAL_PARCELAS numeric(15,2);
begin
  for
    Select
        x.codemp
      , x.Codcli
      , coalesce(v.Prazo_01, 0)
      , v.Prazo_02
      , v.Prazo_03
      , v.Prazo_04
      , v.Prazo_05
      , v.Prazo_06
      , v.Prazo_07
      , v.Prazo_08
      , v.Prazo_09
      , v.Prazo_10
      , v.Prazo_11
      , v.Prazo_12
      , case when coalesce(v.Prazo_01, 0) is not null then 1 else 0 end +
        case when v.Prazo_02 is not null then 1 else 0 end +
        case when v.Prazo_03 is not null then 1 else 0 end +
        case when v.Prazo_04 is not null then 1 else 0 end +
        case when v.Prazo_05 is not null then 1 else 0 end +
        case when v.Prazo_06 is not null then 1 else 0 end +
        case when v.Prazo_07 is not null then 1 else 0 end +
        case when v.Prazo_08 is not null then 1 else 0 end +
        case when v.Prazo_09 is not null then 1 else 0 end +
        case when v.Prazo_10 is not null then 1 else 0 end +
        case when v.Prazo_11 is not null then 1 else 0 end +
        case when v.Prazo_12 is not null then 1 else 0 end as parcelas
      , v.valor_fpagto
      , v.Formapagto_cod
      , x.Dtfinalizacao_venda
    from TBVENDAS x
      inner join TBVENDAS_FORMAPAGTO v on (v.ano_venda = x.ano and v.controle_venda = x.codcontrol)
    where x.Ano        = :Anovenda
      and x.Codcontrol = :Numvenda
    into
        empresa
      , cliente
      , p01
      , p02
      , p03
      , p04
      , p05
      , p06
      , p07
      , p08
      , p09
      , p10
      , p11
      , p12
      , parcelas
      , valor_total
      , forma_pagto
      , data_finaliz_venda
  do
  begin

    parcela = 0;
    emissao = :Data_finaliz_venda;
    valor_documento = :Valor_total / :Parcelas;

    -- Parcela 1
    if ( :P01 is not null ) then
    begin
      if ( :P01 = 0 ) then
        parcela = 0;
      else
      if ( :P01 > 0 ) then
        parcela = 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P01) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 2
    if ( :P02 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P02) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 3
    if ( :P03 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P03) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 4
    if ( :P04 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P04) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 5
    if ( :P05 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P05) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 6
    if ( :P06 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P06) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 7
    if ( :P07 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P07) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 8
    if ( :P08 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P08) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 9
    if ( :P09 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P09) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 10
    if ( :P10 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P10) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 11
    if ( :P11 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P11) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 12
    if ( :P12 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P12) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Verificar ao valor total das parcelas
    if ( :Parcelas > 1 ) then
    begin
      Select
          sum( coalesce(r.Valorrec, 0) )
      from TBCONTREC r
      where r.Anovenda = :Anovenda
        and r.Numvenda = :Numvenda
        and r.forma_pagto = :forma_pagto
      into
          valor_total_parcelas;

      -- Atualizar o valor da ultima parcela
      if ( :Valor_total_parcelas < :Valor_total ) then
      begin
        Update TBCONTREC r Set
            r.Valorrec = :Valor_documento + (:Valor_total - :Valor_total_parcelas)
        where r.Anovenda = :Anovenda
          and r.Numvenda = :Numvenda
          and r.forma_pagto = :forma_pagto
          and r.Parcela  = :Parcela;
      end 
    end 

  end
end^

SET TERM ; ^




/*------ SYSDBA 17/09/2013 00:41:05 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_TITULO_RECEBER (
    ANOVENDA smallint,
    NUMVENDA integer,
    EMPRESA varchar(18),
    CLIENTE varchar(18),
    FORMA_PAGTO smallint,
    EMISSAO date,
    VENCIMENTO date,
    VALOR_DOCUMENTO numeric(15,2),
    PARCELA smallint)
returns (
    ANOLANCAMENTO smallint,
    NUMLANCAMENTO integer)
as
declare variable FORMA_PAGTO_DESC varchar(30);
begin
  if ( Exists(
    Select
      r.Numlanc
    from TBCONTREC r
    where r.Anovenda = :Anovenda
      and r.Numvenda = :Numvenda
      and r.Parcela  = :Parcela
  ) ) then
    Exit;

  Select
    f.Descri
  from TBFORMPAGTO f
  where f.Cod = :Forma_pagto
  into
    Forma_pagto_desc;

  Anolancamento = :Anovenda;

  if ( :Anolancamento = 2011 ) then
    Numlancamento = gen_id(Gen_contarec_num_2011, 1);
  else
  if ( :Anolancamento = 2012 ) then
    Numlancamento = gen_id(Gen_contarec_num_2012, 1);
  else
  if ( :Anolancamento = 2013 ) then
    Numlancamento = gen_id(Gen_contarec_num_2013, 1);
  else
  if ( :Anolancamento = 2014 ) then
    Numlancamento = gen_id(Gen_contarec_num_2014, 1);
  else
  if ( :Anolancamento = 2015 ) then
    Numlancamento = gen_id(Gen_contarec_num_2015, 1);
  else
  if ( :Anolancamento = 2016 ) then
    Numlancamento = gen_id(Gen_contarec_num_2016, 1);
  else
  if ( :Anolancamento = 2017 ) then
    Numlancamento = gen_id(Gen_contarec_num_2017, 1);
  else
  if ( :Anolancamento = 2018 ) then
    Numlancamento = gen_id(Gen_contarec_num_2018, 1);
  else
  if ( :Anolancamento = 2019 ) then
    Numlancamento = gen_id(Gen_contarec_num_2019, 1);
  else
  if ( :Anolancamento = 2020 ) then
    Numlancamento = gen_id(Gen_contarec_num_2020, 1);

  Insert Into TBCONTREC (
      Anolanc
    , numlanc
    , Anovenda
    , Numvenda
    , Empresa
    , Cnpj
    , Tippag
    , Forma_pagto
    , Dtemiss
    , Dtvenc
    , Valorrec
    , Parcela
    , Percentjuros
    , Percentmulta
    , Percentdesconto
    , Baixado
    , Enviado
    , Situacao
  ) values (
      :Anolancamento
    , :Numlancamento
    , :Anovenda
    , :Numvenda
    , :Empresa
    , :Cliente
    , :Forma_pagto_desc
    , :Forma_pagto
    , :Emissao
    , :Vencimento
    , :Valor_documento
    , :Parcela
    , 0
    , 0
    , 0
    , 0
    , 0
    , 1
  );

  suspend;
end^

SET TERM ; ^




/*------ SYSDBA 17/09/2013 00:43:45 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_GERAR_TITULOS (
    ANOVENDA smallint,
    NUMVENDA integer)
returns (
    EMPRESA varchar(18),
    CLIENTE varchar(18),
    PARCELAS smallint,
    VALOR_TOTAL numeric(15,2),
    PARCELA smallint,
    EMISSAO date,
    VENCIMENTO date,
    VALOR_DOCUMENTO numeric(15,2),
    FORMA_PAGTO smallint,
    DATA_FINALIZ_VENDA date,
    ANO_LANC smallint,
    NUM_LANC integer)
as
declare variable P01 smallint;
declare variable P02 smallint;
declare variable P03 smallint;
declare variable P04 smallint;
declare variable P05 smallint;
declare variable P06 smallint;
declare variable P07 smallint;
declare variable P08 smallint;
declare variable P09 smallint;
declare variable P10 smallint;
declare variable P11 smallint;
declare variable P12 smallint;
declare variable VALOR_TOTAL_PARCELAS numeric(15,2);
begin
  for
    Select
        x.codemp
      , x.Codcli
      , coalesce(v.Prazo_01, 0)
      , v.Prazo_02
      , v.Prazo_03
      , v.Prazo_04
      , v.Prazo_05
      , v.Prazo_06
      , v.Prazo_07
      , v.Prazo_08
      , v.Prazo_09
      , v.Prazo_10
      , v.Prazo_11
      , v.Prazo_12
      , case when coalesce(v.Prazo_01, 0) is not null then 1 else 0 end +
        case when v.Prazo_02 is not null then 1 else 0 end +
        case when v.Prazo_03 is not null then 1 else 0 end +
        case when v.Prazo_04 is not null then 1 else 0 end +
        case when v.Prazo_05 is not null then 1 else 0 end +
        case when v.Prazo_06 is not null then 1 else 0 end +
        case when v.Prazo_07 is not null then 1 else 0 end +
        case when v.Prazo_08 is not null then 1 else 0 end +
        case when v.Prazo_09 is not null then 1 else 0 end +
        case when v.Prazo_10 is not null then 1 else 0 end +
        case when v.Prazo_11 is not null then 1 else 0 end +
        case when v.Prazo_12 is not null then 1 else 0 end as parcelas
      , v.valor_fpagto
      , v.Formapagto_cod
      , x.Dtfinalizacao_venda
    from TBVENDAS x
      inner join TBVENDAS_FORMAPAGTO v on (v.ano_venda = x.ano and v.controle_venda = x.codcontrol)
    where x.Ano        = :Anovenda
      and x.Codcontrol = :Numvenda
    into
        empresa
      , cliente
      , p01
      , p02
      , p03
      , p04
      , p05
      , p06
      , p07
      , p08
      , p09
      , p10
      , p11
      , p12
      , parcelas
      , valor_total
      , forma_pagto
      , data_finaliz_venda
  do
  begin

    parcela = 0;
    emissao = :Data_finaliz_venda;
    valor_documento = :Valor_total / :Parcelas;

    -- Parcela 1
    if ( :P01 is not null ) then
    begin
      if ( :P01 = 0 ) then
        parcela = 0;
      else
      if ( :P01 > 0 ) then
        parcela = 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P01) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 2
    if ( :P02 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P02) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 3
    if ( :P03 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P03) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 4
    if ( :P04 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P04) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 5
    if ( :P05 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P05) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 6
    if ( :P06 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P06) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 7
    if ( :P07 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P07) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 8
    if ( :P08 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P08) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 9
    if ( :P09 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P09) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 10
    if ( :P10 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P10) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 11
    if ( :P11 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P11) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Parcela 12
    if ( :P12 is not null ) then
    begin
      parcela = :Parcela + 1;

      Select d.Dia_util from Get_dia_util(:Emissao, :P12) d into vencimento;

      Select
          t.Anolancamento
        , t.Numlancamento
      from SET_TITULO_RECEBER (
          :Anovenda
        , :Numvenda
        , :Empresa
        , :Cliente
        , :Forma_pagto
        , :Emissao
        , :Vencimento
        , :Valor_documento
        , :Parcela) t
      into
          Ano_lanc
        , Num_lanc;
    end

    -- Verificar ao valor total das parcelas
    if ( :Parcelas > 1 ) then
    begin
      Select
          sum( coalesce(r.Valorrec, 0) )
      from TBCONTREC r
      where r.Anovenda = :Anovenda
        and r.Numvenda = :Numvenda
        and r.forma_pagto = :forma_pagto
      into
          valor_total_parcelas;

      -- Atualizar o valor da ultima parcela
      if ( :Valor_total_parcelas < :Valor_total ) then
      begin
        Update TBCONTREC r Set
            r.Valorrec = :Valor_documento + (:Valor_total - :Valor_total_parcelas)
        where r.Anovenda = :Anovenda
          and r.Numvenda = :Numvenda
          and r.forma_pagto = :forma_pagto
          and r.Parcela  = :Parcela;
      end 
    end 

  end
end^

SET TERM ; ^




/*------ SYSDBA 17/09/2013 00:49:04 --------*/

ALTER TABLE TBCONTREC
ADD CONSTRAINT FK_TBCONTREC_EMPRESA
FOREIGN KEY (EMPRESA)
REFERENCES TBEMPRESA(CNPJ);




/*------ SYSDBA 17/09/2013 18:20:33 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_cancelar for tbvendas
active after update position 2
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 5)) then
  begin

    -- Retornar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , valor_produto
    do
    begin
      estoque = :Estoque + :Quantidade;

      -- Retornar estoque
      Update TBPRODUTO p Set
        p.Qtde = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - VENDA CANCELADA'
        , Current_time
        , :Estoque - :Quantidade
        , :Quantidade
        , :Estoque
        , new.Cancel_usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );

    end

    -- Cancelar Contas A Receber (Apenas parcelas nao pagas)
    Update TBCONTREC r Set
        r.status   = 'CANCELADA'
      , r.Situacao = 0 -- Cancelado
      , r.enviado  = 0 -- Enviar boleto novamente para o banco
    where r.anovenda = new.ano
      and r.numvenda = new.codcontrol
      and coalesce(r.Valorrectot, 0) = 0;

    -- Cancelar Movimento Caixa
    Update TBCAIXA_MOVIMENTO m Set
      m.Situacao = 0 -- Cancelado
    where m.Empresa = new.Codemp
      and m.Cliente = new.Codcli
      and m.Venda_ano = new.Ano
      and m.Venda_num = new.Codcontrol;
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 25/09/2013 16:07:47 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.CODPROD IS
'Produto';




/*------ SYSDBA 25/09/2013 16:07:50 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.CODEMPRESA IS
'Empresa';




/*------ SYSDBA 25/09/2013 16:07:53 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.CODFORN IS
'Fornecedor';




/*------ SYSDBA 25/09/2013 16:07:55 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.QTDEATUAL IS
'Quantidade atual';




/*------ SYSDBA 25/09/2013 16:07:58 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.QTDENOVA IS
'Quantidade de entrada ou saida';




/*------ SYSDBA 25/09/2013 16:08:01 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.QTDEFINAL IS
'Quantidade final:
Quantidade atual + Quantidade de entrada ou saida';




/*------ SYSDBA 25/09/2013 16:08:20 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_VCHAR_250'
where (RDB$FIELD_NAME = 'MOTIVO') and
(RDB$RELATION_NAME = 'TBAJUSTESTOQ')
;




/*------ SYSDBA 25/09/2013 16:08:25 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.DOC IS
'Documento';




/*------ SYSDBA 25/09/2013 16:08:29 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.DTAJUST IS
'Data/Hora do ajuste';




/*------ SYSDBA 25/09/2013 16:08:32 --------*/

COMMENT ON COLUMN TBAJUSTESTOQ.USUARIO IS
'Usuario';




/*------ SYSDBA 25/09/2013 16:08:44 --------*/

ALTER TABLE TBAJUSTESTOQ DROP CODEMPRESA;




/*------ SYSDBA 25/09/2013 16:09:11 --------*/

ALTER TABLE TBAJUSTESTOQ
    ADD CODEMPRESA DMN_CNPJ;

COMMENT ON COLUMN TBAJUSTESTOQ.CODEMPRESA IS
'Empresa';

alter table TBAJUSTESTOQ
alter CODPROD position 1;

alter table TBAJUSTESTOQ
alter CODEMPRESA position 2;

alter table TBAJUSTESTOQ
alter CODFORN position 3;

alter table TBAJUSTESTOQ
alter QTDEATUAL position 4;

alter table TBAJUSTESTOQ
alter QTDENOVA position 5;

alter table TBAJUSTESTOQ
alter QTDEFINAL position 6;

alter table TBAJUSTESTOQ
alter MOTIVO position 7;

alter table TBAJUSTESTOQ
alter DOC position 8;

alter table TBAJUSTESTOQ
alter DTAJUST position 9;

alter table TBAJUSTESTOQ
alter USUARIO position 10;




/*------ SYSDBA 25/09/2013 16:09:32 --------*/

ALTER TABLE TBAJUSTESTOQ
ADD CONSTRAINT FK_TBAJUSTESTOQ_EMP
FOREIGN KEY (CODEMPRESA)
REFERENCES TBEMPRESA(CNPJ);




/*------ SYSDBA 25/09/2013 16:10:25 --------*/

ALTER TABLE TBAJUSTESTOQ
    ADD CONTROLE DMN_BIGINT_NN;

COMMENT ON COLUMN TBAJUSTESTOQ.CONTROLE IS
'Codigo';

alter table TBAJUSTESTOQ
alter CONTROLE position 1;

alter table TBAJUSTESTOQ
alter CODPROD position 2;

alter table TBAJUSTESTOQ
alter CODEMPRESA position 3;

alter table TBAJUSTESTOQ
alter CODFORN position 4;

alter table TBAJUSTESTOQ
alter QTDEATUAL position 5;

alter table TBAJUSTESTOQ
alter QTDENOVA position 6;

alter table TBAJUSTESTOQ
alter QTDEFINAL position 7;

alter table TBAJUSTESTOQ
alter MOTIVO position 8;

alter table TBAJUSTESTOQ
alter DOC position 9;

alter table TBAJUSTESTOQ
alter DTAJUST position 10;

alter table TBAJUSTESTOQ
alter USUARIO position 11;




/*------ SYSDBA 25/09/2013 16:10:47 --------*/

ALTER TABLE TBAJUSTESTOQ
ADD CONSTRAINT PK_TBAJUSTESTOQ
PRIMARY KEY (CONTROLE);




/*------ SYSDBA 25/09/2013 16:44:43 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger trgajustestoq for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    qtde = coalesce(qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , 'AJUSTE DE ESTOQUE - ENTRADA'
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , new.motivo
  );
end^

SET TERM ; ^




/*------ SYSDBA 25/09/2013 16:45:13 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger trgajustestoq for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    qtde = coalesce(qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , 'AJUSTE DE ESTOQUE - ENTRADA'
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , substring(trim(new.motivo) from 1 for 40)
  );
end^

SET TERM ; ^




/*------ SYSDBA 25/09/2013 16:45:38 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger trgajustestoq for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    p.qtde = coalesce(p.qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , 'AJUSTE DE ESTOQUE - ENTRADA'
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , substring(trim(new.motivo) from 1 for 40)
  );
end^

SET TERM ; ^




/*------ SYSDBA 08/10/2013 11:08:05 --------*/

COMMENT ON COLUMN TBBAIRRO.BAI_COD IS
'Codigo';




/*------ SYSDBA 08/10/2013 11:08:11 --------*/

COMMENT ON COLUMN TBBAIRRO.BAI_NOME IS
'Nome';




/*------ SYSDBA 08/10/2013 11:08:15 --------*/

COMMENT ON COLUMN TBBAIRRO.CID_COD IS
'Cidade';




/*------ SYSDBA 08/10/2013 11:08:20 --------*/

COMMENT ON COLUMN TBBAIRRO.DIS_COD IS
'Distrito';




/*------ SYSDBA 08/10/2013 11:14:52 --------*/

SET TERM ^ ;

create or alter procedure SET_BAIRRO (
    NOM_BAIRRO varchar(100),
    COD_CIDADE integer,
    COD_DISTRITO integer)
returns (
    COD_BAIRRO integer)
as
begin
  /* 1. Buscar codigo do Bairro */
  Select first 1
    b.bai_cod
  from TBBAIRRO b
  where b.cid_cod = :cod_cidade
    and trim(b.bai_nome) = Trim(:nom_bairro)
  Into
    cod_bairro;

  /* 2. Inserir bairro caso ele nao exista */
  if ( coalesce(:cod_bairro, 0) = 0 ) then
  begin
    cod_bairro = Gen_id(GEN_BAIRRO_ID, 1);
    Insert Into TBBAIRRO (
        bai_cod
      , bai_nome
      , cid_cod
      , dis_cod
    ) values (
        :cod_bairro
      , :nom_bairro
      , :cod_cidade
      , :cod_distrito
    );
  end 

  suspend;
end^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE SET_BAIRRO TO "PUBLIC";



/*------ SYSDBA 08/10/2013 11:15:47 --------*/

COMMENT ON COLUMN TBLOGRADOURO.LOG_COD IS
'Codigo';




/*------ SYSDBA 08/10/2013 11:15:52 --------*/

COMMENT ON COLUMN TBLOGRADOURO.LOG_NOME IS
'Descricao';




/*------ SYSDBA 08/10/2013 11:15:59 --------*/

COMMENT ON COLUMN TBLOGRADOURO.TLG_COD IS
'Tipo';




/*------ SYSDBA 08/10/2013 11:16:09 --------*/

COMMENT ON COLUMN TBLOGRADOURO.CID_COD IS
'Cidade';




/*------ SYSDBA 08/10/2013 11:28:07 --------*/

SET TERM ^ ;

create or alter procedure SET_LOGRADOURO (
    NOM_LOGRADOURO varchar(250),
    TIP_LOGRADOURO varchar(5),
    COD_CIDADE integer)
returns (
    COD_LOGRADOURO integer)
as
declare variable TMP_TIPO smallint;
declare variable TMP_DESC varchar(250);
begin
  /* 1. Buscar codigo do Tipo do Logradouro */
  Select first 1
    t.tlg_cod
  from TBTIPO_LOGRADOURO t
  where coalesce(t.tlg_sigla, t.tlg_descricao) like Trim(:tip_logradouro) || '%'
  Into
    tmp_tipo;

  /* 2. Ajustar descricao do logradouro */
  if ( coalesce(:tmp_tipo, 0) = 0 ) then
    tmp_desc = trim(:tip_logradouro) || ' ' || trim(:nom_logradouro);
  else
    tmp_desc = trim(:nom_logradouro);

  /* 3. Buscar codigo do Logradouro */
  Select first 1
    l.log_cod
  from TBLOGRADOURO l
  where l.cid_cod = :cod_cidade
    and trim(l.log_nome) = Trim(:tmp_desc)
  Into
    cod_logradouro;

  /* 4. Inserir Logradouro, caso ele nao exista */
  if ( coalesce(:cod_logradouro, 0) = 0 ) then
  begin
    cod_logradouro = Gen_id(GEN_LOGRADOURO_ID, 1);
    Insert Into TBLOGRADOURO (
        log_cod
      , log_nome
      , tlg_cod
      , cid_cod
    ) values (
        :cod_logradouro
      , :tmp_desc
      , :tmp_tipo
      , :cod_cidade
    );
  end

  suspend;
end^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE SET_LOGRADOURO TO "PUBLIC";



/*------ SYSDBA 08/10/2013 11:48:46 --------*/

SET TERM ^ ;

CREATE OR ALTER procedure SET_LOGRADOURO (
    NOM_LOGRADOURO varchar(250),
    TIP_LOGRADOURO varchar(10),
    COD_CIDADE integer)
returns (
    COD_LOGRADOURO integer)
as
declare variable TMP_TIPO smallint;
declare variable TMP_DESC varchar(250);
begin
  /* 1. Buscar codigo do Tipo do Logradouro */
  Select first 1
    t.tlg_cod
  from TBTIPO_LOGRADOURO t
  where coalesce(t.tlg_sigla, t.tlg_descricao) like Trim(:tip_logradouro) || '%'
  Into
    tmp_tipo;

  /* 2. Ajustar descricao do logradouro */
  if ( coalesce(:tmp_tipo, 0) = 0 ) then
    tmp_desc = trim(:tip_logradouro) || ' ' || trim(:nom_logradouro);
  else
    tmp_desc = trim(:nom_logradouro);

  /* 3. Buscar codigo do Logradouro */
  Select first 1
    l.log_cod
  from TBLOGRADOURO l
  where l.cid_cod = :cod_cidade
    and trim(l.log_nome) = Trim(:tmp_desc)
  Into
    cod_logradouro;

  /* 4. Inserir Logradouro, caso ele nao exista */
  if ( coalesce(:cod_logradouro, 0) = 0 ) then
  begin
    cod_logradouro = Gen_id(GEN_LOGRADOURO_ID, 1);
    Insert Into TBLOGRADOURO (
        log_cod
      , log_nome
      , tlg_cod
      , cid_cod
    ) values (
        :cod_logradouro
      , :tmp_desc
      , :tmp_tipo
      , :cod_cidade
    );
  end

  suspend;
end^

SET TERM ; ^




/*------ SYSDBA 15/10/2013 21:35:16 --------*/

ALTER TABLE TBFORNECEDOR
    ADD DTCAD DMN_DATE;

COMMENT ON COLUMN TBFORNECEDOR.DTCAD IS
'Data de Cadastro.';




/*------ SYSDBA 15/10/2013 21:49:01 --------*/

ALTER TABLE TBFORNECEDOR
    ADD FONECEL DMN_FONERSD,
    ADD FONEFAX DMN_FONERSD;

COMMENT ON COLUMN TBFORNECEDOR.FONE IS
'Telefone Comercial.';

COMMENT ON COLUMN TBFORNECEDOR.FONECEL IS
'Telefone Movel.';

COMMENT ON COLUMN TBFORNECEDOR.FONEFAX IS
'Fax.';

alter table TBFORNECEDOR
alter CODFORN position 1;

alter table TBFORNECEDOR
alter PESSOA_FISICA position 2;

alter table TBFORNECEDOR
alter NOMEFORN position 3;

alter table TBFORNECEDOR
alter CNPJ position 4;

alter table TBFORNECEDOR
alter INSCEST position 5;

alter table TBFORNECEDOR
alter INSCMUN position 6;

alter table TBFORNECEDOR
alter ENDER position 7;

alter table TBFORNECEDOR
alter COMPLEMENTO position 8;

alter table TBFORNECEDOR
alter NUMERO_END position 9;

alter table TBFORNECEDOR
alter CEP position 10;

alter table TBFORNECEDOR
alter CIDADE position 11;

alter table TBFORNECEDOR
alter UF position 12;

alter table TBFORNECEDOR
alter CONTATO position 13;

alter table TBFORNECEDOR
alter FONE position 14;

alter table TBFORNECEDOR
alter FONECEL position 15;

alter table TBFORNECEDOR
alter FONEFAX position 16;

alter table TBFORNECEDOR
alter EMAIL position 17;

alter table TBFORNECEDOR
alter SITE position 18;

alter table TBFORNECEDOR
alter TLG_TIPO position 19;

alter table TBFORNECEDOR
alter LOG_COD position 20;

alter table TBFORNECEDOR
alter BAI_COD position 21;

alter table TBFORNECEDOR
alter CID_COD position 22;

alter table TBFORNECEDOR
alter EST_COD position 23;

alter table TBFORNECEDOR
alter PAIS_ID position 24;

alter table TBFORNECEDOR
alter GRF_COD position 25;

alter table TBFORNECEDOR
alter TRANSPORTADORA position 26;

alter table TBFORNECEDOR
alter DTCAD position 27;




/*------ SYSDBA 15/10/2013 21:57:45 --------*/

ALTER TABLE TBCLIENTE
    ADD EMITIR_NFE_DEVOLUCAO DMN_SMALLINT_N;

COMMENT ON COLUMN TBCLIENTE.EMITIR_NFE_DEVOLUCAO IS
'Emitir NF-e de devolucao para o cliente:
0 - Nao
1 - Sim';




/*------ SYSDBA 15/10/2013 21:59:49 --------*/

ALTER TABLE TBFORNECEDOR
    ADD CLIENTE_ORIGEM DMN_CNPJ;

COMMENT ON COLUMN TBFORNECEDOR.CLIENTE_ORIGEM IS
'FORNECEDOR corresponde a CLIENTE cadastrado.';




/*------ SYSDBA 15/10/2013 22:19:02 --------*/

SET TERM ^ ;

CREATE trigger tg_cliente_gerar_fornecedor for tbcliente
active after insert or update position 1
AS
  declare variable codigo_forn Integer;
  declare variable grupo_forn Smallint;
begin
  if ( new.emitir_nfe_devolucao = 1 ) then
  begin
    /* Buscar Fornecedor referenre ao CPF/CNPJ */
    Select first 1
      f.codforn
    from TBFORNECEDOR f
    where f.cnpj = new.cnpj
    Into
      codigo_forn;

    if ( :codigo_forn is null ) then
    begin
      /* Buscar Grupo de fornecedor */
      Select first 1
        g.grf_cod
      from TBFORNECEDOR_GRUPO g
      Into
        grupo_forn;

      codigo_forn = Gen_id(GEN_FORNECEDOR_ID, 1);
      Insert Into TBFORNECEDOR (
          CODFORN
        , PESSOA_FISICA
        , NOMEFORN
        , CNPJ
        , INSCEST
        , INSCMUN
        , ENDER
        , COMPLEMENTO
        , NUMERO_END
        , CEP
        , CIDADE
        , UF
        , FONE
        , FONECEL
        , EMAIL
        , SITE
        , TLG_TIPO
        , LOG_COD
        , BAI_COD
        , CID_COD
        , EST_COD
        , PAIS_ID
        , GRF_COD
        , TRANSPORTADORA
        , DTCAD
        , CLIENTE_ORIGEM
      ) values (
          :codigo_forn
        , new.pessoa_fisica
        , new.nome
        , new.cnpj
        , new.inscest
        , new.inscmun
        , new.ender
        , new.complemento
        , new.numero_end
        , new.cep
        , new.cidade
        , new.uf
        , new.fone
        , new.fonecel
        , substring(new.email from 1 for 40)
        , substring(new.site from 1 for 35)
        , new.tlg_tipo
        , new.log_cod
        , new.bai_cod
        , new.cid_cod
        , new.est_cod
        , new.pais_id
        , :grupo_forn
        , 0
        , current_date
        , new.cnpj
      );
    end
    else
    begin
      Update TBFORNECEDOR f Set
          f.pessoa_fisica = new.pessoa_fisica
        , f.nomeforn = new.nome
        , f.cnpj     = new.cnpj
        , f.inscest = new.inscest
        , f.inscmun = new.inscmun
        , f.ender   = new.ender
        , f.complemento = new.complemento
        , f.numero_end  = new.numero_end
        , f.cep    = new.cep
        , f.cidade = new.cidade
        , f.uf     = new.uf
        , f.fone    = new.fone
        , f.fonecel = new.fonecel
        , f.email   = substring(new.email from 1 for 40)
        , f.site    = substring(new.site from 1 for 35)
        , f.tlg_tipo = new.tlg_tipo
        , f.log_cod = new.log_cod
        , f.bai_cod = new.bai_cod
        , f.cid_cod = new.cid_cod
        , f.est_cod = new.est_cod
        , f.pais_id = new.pais_id
        , f.cliente_origem =  new.cnpj
      where f.codforn = :codigo_forn;
    end 
  end 
end^

SET TERM ; ^




/*------ SYSDBA 15/10/2013 22:25:10 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cliente_gerar_fornecedor for tbcliente
active after insert or update position 1
AS
  declare variable codigo_forn Integer;
  declare variable grupo_forn Smallint;
begin
  if ( new.emitir_nfe_devolucao = 1 ) then
  begin
    /* Buscar Fornecedor referenre ao CPF/CNPJ */
    Select first 1
      f.codforn
    from TBFORNECEDOR f
    where f.cliente_origem = new.cnpj
    Into
      codigo_forn;

    if ( :codigo_forn is null ) then
    begin
      /* Buscar Grupo de fornecedor */
      Select first 1
        g.grf_cod
      from TBFORNECEDOR_GRUPO g
      Into
        grupo_forn;

      codigo_forn = Gen_id(GEN_FORNECEDOR_ID, 1);
      Insert Into TBFORNECEDOR (
          CODFORN
        , PESSOA_FISICA
        , NOMEFORN
        , CNPJ
        , INSCEST
        , INSCMUN
        , ENDER
        , COMPLEMENTO
        , NUMERO_END
        , CEP
        , CIDADE
        , UF
        , FONE
        , FONECEL
        , EMAIL
        , SITE
        , TLG_TIPO
        , LOG_COD
        , BAI_COD
        , CID_COD
        , EST_COD
        , PAIS_ID
        , GRF_COD
        , TRANSPORTADORA
        , DTCAD
        , CLIENTE_ORIGEM
      ) values (
          :codigo_forn
        , new.pessoa_fisica
        , new.nome
        , new.cnpj
        , new.inscest
        , new.inscmun
        , new.ender
        , new.complemento
        , new.numero_end
        , new.cep
        , new.cidade
        , new.uf
        , new.fone
        , new.fonecel
        , substring(new.email from 1 for 40)
        , substring(new.site from 1 for 35)
        , new.tlg_tipo
        , new.log_cod
        , new.bai_cod
        , new.cid_cod
        , new.est_cod
        , new.pais_id
        , :grupo_forn
        , 0
        , current_date
        , new.cnpj
      );
    end
    else
    begin
      Update TBFORNECEDOR f Set
          f.pessoa_fisica = new.pessoa_fisica
        , f.nomeforn = new.nome
        , f.cnpj     = new.cnpj
        , f.inscest = new.inscest
        , f.inscmun = new.inscmun
        , f.ender   = new.ender
        , f.complemento = new.complemento
        , f.numero_end  = new.numero_end
        , f.cep    = new.cep
        , f.cidade = new.cidade
        , f.uf     = new.uf
        , f.fone    = new.fone
        , f.fonecel = new.fonecel
        , f.email   = substring(new.email from 1 for 40)
        , f.site    = substring(new.site from 1 for 35)
        , f.tlg_tipo = new.tlg_tipo
        , f.log_cod = new.log_cod
        , f.bai_cod = new.bai_cod
        , f.cid_cod = new.cid_cod
        , f.est_cod = new.est_cod
        , f.pais_id = new.pais_id
        , f.cliente_origem =  new.cnpj
      where f.codforn = :codigo_forn;
    end 
  end 
end^

SET TERM ; ^




/*------ SYSDBA 15/10/2013 22:27:18 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cliente_gerar_fornecedor for tbcliente
active after insert or update position 1
AS
  declare variable codigo_forn Integer;
  declare variable grupo_forn Smallint;
begin
  if ( new.emitir_nfe_devolucao = 1 ) then
  begin
    /* Buscar Fornecedor referenre ao CPF/CNPJ */
    Select first 1
      f.codforn
    from TBFORNECEDOR f
    where f.cliente_origem = new.cnpj
    Into
      codigo_forn;

    if ( :codigo_forn is null ) then
    begin
      /* Buscar Grupo de fornecedor */
      Select first 1
        g.grf_cod
      from TBFORNECEDOR_GRUPO g
      Into
        grupo_forn;

      codigo_forn = Gen_id(GEN_FORNECEDOR_ID, 1);
      Insert Into TBFORNECEDOR (
          CODFORN
        , PESSOA_FISICA
        , NOMEFORN
        , CNPJ
        , INSCEST
        , INSCMUN
        , ENDER
        , COMPLEMENTO
        , NUMERO_END
        , CEP
        , CIDADE
        , UF
        , FONE
        , FONECEL
        , EMAIL
        , SITE
        , TLG_TIPO
        , LOG_COD
        , BAI_COD
        , CID_COD
        , EST_COD
        , PAIS_ID
        , GRF_COD
        , TRANSPORTADORA
        , DTCAD
        , CLIENTE_ORIGEM
      ) values (
          :codigo_forn
        , new.pessoa_fisica
        , new.nome
        , new.cnpj
        , new.inscest
        , new.inscmun
        , new.ender
        , new.complemento
        , new.numero_end
        , new.cep
        , new.cidade
        , new.uf
        , new.fone
        , new.fonecel
        , substring(new.email from 1 for 40)
        , substring(new.site from 1 for 35)
        , new.tlg_tipo
        , new.log_cod
        , new.bai_cod
        , new.cid_cod
        , new.est_cod
        , new.pais_id
        , :grupo_forn
        , 0
        , current_date
        , new.cnpj
      );
    end
    else
    begin
      Update TBFORNECEDOR f Set
          f.pessoa_fisica = new.pessoa_fisica
        , f.nomeforn = new.nome
        , f.cnpj     = new.cnpj
        , f.inscest = new.inscest
        , f.inscmun = new.inscmun
        , f.ender   = new.ender
        , f.complemento = new.complemento
        , f.numero_end  = new.numero_end
        , f.cep    = new.cep
        , f.cidade = new.cidade
        , f.uf     = new.uf
        , f.fone    = new.fone
        , f.fonecel = new.fonecel
        , f.email   = substring(new.email from 1 for 40)
        , f.site    = substring(new.site from 1 for 35)
        , f.tlg_tipo = new.tlg_tipo
        , f.log_cod = new.log_cod
        , f.bai_cod = new.bai_cod
        , f.cid_cod = new.cid_cod
        , f.est_cod = new.est_cod
        , f.pais_id = new.pais_id
        , f.cliente_origem =  new.cnpj
      where f.codforn = :codigo_forn;
    end 
  end 
end^

SET TERM ; ^

COMMENT ON TRIGGER TG_CLIENTE_GERAR_FORNECEDOR IS 'Trigger Gerar Fornecedor do Cliente.

    Autor   :   Isaque Marinho Ribeiro
    Data    :   15/10/2013

Trigger responsavel por inserir/atualizar um registro de fornecedor corrrespondente ao registro do clientes quando for
permitido para este gerar NF-e de devolucao.';




/*------ SYSDBA 15/10/2013 22:28:22 --------*/

ALTER TABLE TBFORNECEDOR
ADD CONSTRAINT FK_TBFORNECEDOR_CLIENTE
FOREIGN KEY (CLIENTE_ORIGEM)
REFERENCES TBCLIENTE(CNPJ);




/*------ SYSDBA 16/10/2013 13:09:08 --------*/

ALTER TABLE TBCIDADE
    ADD CUSTO_OPER_PERCENTUAL DMN_SMALLINT_N DEFAULT 1,
    ADD CUSTO_OPER_FRETE DMN_PERCENTUAL_3 DEFAULT 0,
    ADD CUSTO_OPER_OUTROS DMN_PERCENTUAL_3 DEFAULT 0;

COMMENT ON COLUMN TBCIDADE.CUSTO_OPER_PERCENTUAL IS
'Custo Operacional em Percentual:
0 - Nao
1 - Sim';

COMMENT ON COLUMN TBCIDADE.CUSTO_OPER_FRETE IS
'Custo Operacional (Frete) - Percentual ou Valor';

COMMENT ON COLUMN TBCIDADE.CUSTO_OPER_OUTROS IS
'Custo Operacional (Outros) - Percentual ou Valor';




/*------ SYSDBA 16/10/2013 13:18:57 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_4'
where (RDB$FIELD_NAME = 'CUSTO_OPER_FRETE') and
(RDB$RELATION_NAME = 'TBCIDADE')
;




/*------ SYSDBA 16/10/2013 13:19:04 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_MONEY_4'
where (RDB$FIELD_NAME = 'CUSTO_OPER_OUTROS') and
(RDB$RELATION_NAME = 'TBCIDADE')
;




/*------ SYSDBA 16/10/2013 13:20:13 --------*/

ALTER TABLE TBVENDAS
    ADD CUSTO_OPER_PERCENTUAL DMN_SMALLINT_N DEFAULT 1,
    ADD CUSTO_OPER_FRETE DMN_MONEY_4 DEFAULT 0,
    ADD CUSTO_OPER_OUTROS DMN_MONEY_4;

COMMENT ON COLUMN TBVENDAS.CUSTO_OPER_PERCENTUAL IS
'Custo Operacional em Percentual:
0 - Nao
1 - Sim';

COMMENT ON COLUMN TBVENDAS.CUSTO_OPER_FRETE IS
' Custo Operacional (Frete) - Percentual ou Valor';

COMMENT ON COLUMN TBVENDAS.CUSTO_OPER_OUTROS IS
'Custo Operacional (Outros) - Percentual ou Valor';




/*------ SYSDBA 16/10/2013 13:20:23 --------*/

ALTER TABLE TBVENDAS ADD IBE$$TEMP_COLUMN
 NUMERIC(1,1) DEFAULT 0
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBVENDAS') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBVENDAS') AND
      (F1.RDB$FIELD_NAME = 'CUSTO_OPER_OUTROS');

ALTER TABLE TBVENDAS DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 16/10/2013 13:43:40 --------*/

SET TERM ^ ;

CREATE trigger tg_cidade_custo_oper for tbcidade
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
  declare variable cliente Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
        , v.codcli
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
      where v.ano = extract(Year from current_date)
        and c.cid_cod = new.cid_cod
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
        , cliente
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = :cliente;

    end
end^

SET TERM ; ^

COMMENT ON TRIGGER TG_CIDADE_CUSTO_OPER IS 'Trigger Definir Custo Operacional (Venda).

    Autor   :   Isaque Marinho Ribeiro
    Data    :   16/10/2013

Trigger responsavel por definir percentuais ou valores de custos operacionais por cada venda realizada dentro de uma
determinada cidade, quando este custo ainda nao fora definido.';




/*------ SYSDBA 16/10/2013 13:50:28 --------*/

ALTER TABLE TBCONFIGURACAO
    ADD CUSTO_OPER_CALCULAR DMN_SMALLINT_N DEFAULT 0;

COMMENT ON COLUMN TBCONFIGURACAO.CUSTO_OPER_CALCULAR IS
'Calcular custo operacional nas vendas:
0 - Nao
1 - Sim';




/*------ SYSDBA 16/10/2013 13:50:56 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cidade_custo_oper for tbcidade
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
  declare variable cliente Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
        , v.codcli
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano     = extract(Year from current_date)
        and c.cid_cod = new.cid_cod
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
        , cliente
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = :cliente;

    end
end^

SET TERM ; ^




/*------ SYSDBA 16/10/2013 13:58:47 --------*/

ALTER TABLE TBCLIENTE
    ADD CUSTO_OPER_PERCENTUAL DMN_SMALLINT_N DEFAULT 1,
    ADD CUSTO_OPER_FRETE DMN_MONEY_4 DEFAULT 0,
    ADD CUSTO_OPER_OUTROS DMN_MONEY_4 DEFAULT 0;

COMMENT ON COLUMN TBCLIENTE.CUSTO_OPER_PERCENTUAL IS
'Custo Operacional em Percentual:
0 - Nao
1 - Sim';

COMMENT ON COLUMN TBCLIENTE.CUSTO_OPER_FRETE IS
'Custo Operacional (Frete) - Percentual ou Valor';

COMMENT ON COLUMN TBCLIENTE.CUSTO_OPER_OUTROS IS
'Custo Operacional (Outros) - Percentual ou Valor';




/*------ SYSDBA 16/10/2013 14:02:42 --------*/

SET TERM ^ ;

CREATE trigger tg_cliente_custo_oper for tbcliente
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
  declare variable cliente Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
        , v.codcli
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano     = extract(Year from current_date)
        and c.cid_cod = new.cnpj
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
        , cliente
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = new.cnpj;

    end
end^

SET TERM ; ^

COMMENT ON TRIGGER TG_CLIENTE_CUSTO_OPER IS 'Trigger Definir Custo Operacional (Venda).

    Autor   :   Isaque Marinho Ribeiro
    Data    :   16/10/2013

Trigger responsavel por definir percentuais ou valores de custos operacionais por cada venda realizada para um
determinado empresa/cliente, quando este custo ainda nao fora definido.';




/*------ SYSDBA 16/10/2013 14:03:01 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cliente_custo_oper for tbcliente
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano     = extract(Year from current_date)
        and c.cid_cod = new.cnpj
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = new.cnpj;

    end
end^

SET TERM ; ^




/*------ SYSDBA 16/10/2013 14:03:31 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cliente_custo_oper for tbcliente
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano     = extract(Year from current_date)
        and c.cid_cod = new.cnpj
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = new.cnpj;

    end
end^

SET TERM ; ^




/*------ SYSDBA 16/10/2013 14:06:15 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cidade_custo_oper for tbcidade
active after insert or update position 10
AS
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    Update TBCLIENTE c Set
        c.custo_oper_percentual = new.custo_oper_percentual
      , c.custo_oper_frete      = new.custo_oper_frete
      , c.custo_oper_outros     = new.custo_oper_outros
    where c.cid_cod = new.cid_cod;
end^

SET TERM ; ^

COMMENT ON TRIGGER TG_CIDADE_CUSTO_OPER IS 'Trigger Definir Custo Operacional (Cliente).

    Autor   :   Isaque Marinho Ribeiro
    Data    :   16/10/2013

Trigger responsavel por definir percentuais ou valores de custos operacionais por cada cliente dentro de uma
determinada cidade, quando este custo ainda nao fora definido.';




/*------ SYSDBA 18/10/2013 19:36:25 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_VCHAR_50'
where (RDB$FIELD_NAME = 'USUARIO') and
(RDB$RELATION_NAME = 'TBAJUSTESTOQ')
;




/*------ SYSDBA 19/10/2013 20:35:45 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger trgajustestoq for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    p.qtde = coalesce(p.qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , case when new.qtdeatual > 0 then 'AJUSTE DE ESTOQUE - ENTRADA' else 'AJUSTE DE ESTOQUE - SAIDA' end
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , substring(trim(new.motivo) from 1 for 40)
  );
end^

SET TERM ; ^




/*------ SYSDBA 19/10/2013 20:36:33 --------*/

DROP TRIGGER TRGAJUSTESTOQ;

SET TERM ^ ;

CREATE OR ALTER trigger tg_ajust_estoque_historico for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    p.qtde = coalesce(p.qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , case when new.qtdeatual > 0 then 'AJUSTE DE ESTOQUE - ENTRADA' else 'AJUSTE DE ESTOQUE - SAIDA' end
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , substring(trim(new.motivo) from 1 for 40)
  );
end^

SET TERM ; ^




/*------ SYSDBA 19/10/2013 21:17:18 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_ajust_estoque_historico for tbajustestoq
active after insert position 0
AS
begin
  update TBPRODUTO p set
    p.qtde = coalesce(p.qtde, 0) + coalesce(new.qtdenova, 0)
  where p.cod    = new.codprod
    and p.codemp = new.codempresa;

  Insert Into TBPRODHIST (
      Codempresa
    , Codprod
    , Doc
    , Historico
    , Dthist
    , Qtdeatual
    , Qtdenova
    , Qtdefinal
    , Resp
    , Motivo
  ) values (
      new.codempresa
    , new.codprod
    , new.doc
    , case when new.qtdenova > 0 then 'AJUSTE DE ESTOQUE - ENTRADA' else 'AJUSTE DE ESTOQUE - SAIDA' end
    , new.dtajust
    , new.qtdeatual
    , new.qtdenova
    , new.qtdefinal
    , coalesce(new.Usuario, user)
    , substring(trim(new.motivo) from 1 for 40)
  );
end^

SET TERM ; ^




/*------ SYSDBA 19/10/2013 21:25:50 --------*/

UPDATE RDB$RELATION_FIELDS F1
SET F1.RDB$DEFAULT_VALUE = NULL,
    F1.RDB$DEFAULT_SOURCE = NULL
WHERE (F1.RDB$RELATION_NAME = 'TBCLIENTE') AND
      (F1.RDB$FIELD_NAME = 'CUSTO_OPER_FRETE');




/*------ SYSDBA 19/10/2013 21:25:56 --------*/

UPDATE RDB$RELATION_FIELDS F1
SET F1.RDB$DEFAULT_VALUE = NULL,
    F1.RDB$DEFAULT_SOURCE = NULL
WHERE (F1.RDB$RELATION_NAME = 'TBCLIENTE') AND
      (F1.RDB$FIELD_NAME = 'CUSTO_OPER_OUTROS');




/*------ SYSDBA 19/10/2013 21:26:08 --------*/

ALTER TABLE TBCLIENTE ADD IBE$$TEMP_COLUMN
 NUMERIC(1,1) DEFAULT 0
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBCLIENTE') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBCLIENTE') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBCLIENTE') AND
      (F1.RDB$FIELD_NAME = 'CUSTO_OPER_FRETE');

ALTER TABLE TBCLIENTE DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 19/10/2013 21:26:12 --------*/

ALTER TABLE TBCLIENTE ADD IBE$$TEMP_COLUMN
 NUMERIC(1,1) DEFAULT 0
;

UPDATE RDB$RELATION_FIELDS F1
SET
F1.RDB$DEFAULT_VALUE  = (SELECT F2.RDB$DEFAULT_VALUE
                         FROM RDB$RELATION_FIELDS F2
                         WHERE (F2.RDB$RELATION_NAME = 'TBCLIENTE') AND
                               (F2.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN')),
F1.RDB$DEFAULT_SOURCE = (SELECT F3.RDB$DEFAULT_SOURCE FROM RDB$RELATION_FIELDS F3
                         WHERE (F3.RDB$RELATION_NAME = 'TBCLIENTE') AND
                               (F3.RDB$FIELD_NAME = 'IBE$$TEMP_COLUMN'))
WHERE (F1.RDB$RELATION_NAME = 'TBCLIENTE') AND
      (F1.RDB$FIELD_NAME = 'CUSTO_OPER_OUTROS');

ALTER TABLE TBCLIENTE DROP IBE$$TEMP_COLUMN;




/*------ SYSDBA 19/10/2013 21:39:41 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_cliente_custo_oper for tbcliente
active after insert or update position 10
AS
  declare variable empresa Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano    = extract(Year from current_date)
        and v.codcli = new.cnpj
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = new.cnpj;

    end
end^

SET TERM ; ^




/*------ SYSDBA 19/10/2013 23:18:08 --------*/

ALTER TABLE TBVENDAS
    ADD CUSTO_OPER_GERAR DMN_SMALLINT_N DEFAULT 0;

COMMENT ON COLUMN TBVENDAS.CUSTO_OPER_GERAR IS
'Gerar Custo Operacional:
0 - Nao
1 - Sim';

alter table TBVENDAS
alter ANO position 1;

alter table TBVENDAS
alter CODCONTROL position 2;

alter table TBVENDAS
alter CODEMP position 3;

alter table TBVENDAS
alter CODCLI position 4;

alter table TBVENDAS
alter DTVENDA position 5;

alter table TBVENDAS
alter STATUS position 6;

alter table TBVENDAS
alter TOTALVENDA_BRUTA position 7;

alter table TBVENDAS
alter DESCONTO position 8;

alter table TBVENDAS
alter TOTALVENDA position 9;

alter table TBVENDAS
alter TOTALCUSTO position 10;

alter table TBVENDAS
alter DTFINALIZACAO_VENDA position 11;

alter table TBVENDAS
alter OBS position 12;

alter table TBVENDAS
alter FORMAPAG position 13;

alter table TBVENDAS
alter FATDIAS position 14;

alter table TBVENDAS
alter SERIE position 15;

alter table TBVENDAS
alter NFE position 16;

alter table TBVENDAS
alter DATAEMISSAO position 17;

alter table TBVENDAS
alter HORAEMISSAO position 18;

alter table TBVENDAS
alter CFOP position 19;

alter table TBVENDAS
alter VERIFICADOR_NFE position 20;

alter table TBVENDAS
alter XML_NFE position 21;

alter table TBVENDAS
alter VENDEDOR_COD position 22;

alter table TBVENDAS
alter USUARIO position 23;

alter table TBVENDAS
alter FORMAPAGTO_COD position 24;

alter table TBVENDAS
alter CONDICAOPAGTO_COD position 25;

alter table TBVENDAS
alter VENDA_PRAZO position 26;

alter table TBVENDAS
alter PRAZO_01 position 27;

alter table TBVENDAS
alter PRAZO_02 position 28;

alter table TBVENDAS
alter PRAZO_03 position 29;

alter table TBVENDAS
alter PRAZO_04 position 30;

alter table TBVENDAS
alter PRAZO_05 position 31;

alter table TBVENDAS
alter PRAZO_06 position 32;

alter table TBVENDAS
alter PRAZO_07 position 33;

alter table TBVENDAS
alter PRAZO_08 position 34;

alter table TBVENDAS
alter PRAZO_09 position 35;

alter table TBVENDAS
alter PRAZO_10 position 36;

alter table TBVENDAS
alter PRAZO_11 position 37;

alter table TBVENDAS
alter PRAZO_12 position 38;

alter table TBVENDAS
alter LOTE_NFE_ANO position 39;

alter table TBVENDAS
alter LOTE_NFE_NUMERO position 40;

alter table TBVENDAS
alter LOTE_NFE_RECIBO position 41;

alter table TBVENDAS
alter NFE_ENVIADA position 42;

alter table TBVENDAS
alter CANCEL_USUARIO position 43;

alter table TBVENDAS
alter CANCEL_DATAHORA position 44;

alter table TBVENDAS
alter CANCEL_MOTIVO position 45;

alter table TBVENDAS
alter XML_NFE_FILENAME position 46;

alter table TBVENDAS
alter NFE_MODALIDADE_FRETE position 47;

alter table TBVENDAS
alter NFE_TRANSPORTADORA position 48;

alter table TBVENDAS
alter NFE_PLACA_VEICULO position 49;

alter table TBVENDAS
alter NFE_PLACA_UF position 50;

alter table TBVENDAS
alter NFE_PLACA_RNTC position 51;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS position 52;

alter table TBVENDAS
alter NFE_VALOR_ICMS position 53;

alter table TBVENDAS
alter NFE_VALOR_BASE_ICMS_SUBST position 54;

alter table TBVENDAS
alter NFE_VALOR_ICMS_SUBST position 55;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_PRODUTO position 56;

alter table TBVENDAS
alter NFE_VALOR_FRETE position 57;

alter table TBVENDAS
alter NFE_VALOR_SEGURO position 58;

alter table TBVENDAS
alter NFE_VALOR_DESCONTO position 59;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_II position 60;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_IPI position 61;

alter table TBVENDAS
alter NFE_VALOR_PIS position 62;

alter table TBVENDAS
alter NFE_VALOR_COFINS position 63;

alter table TBVENDAS
alter NFE_VALOR_OUTROS position 64;

alter table TBVENDAS
alter NFE_VALOR_TOTAL_NOTA position 65;

alter table TBVENDAS
alter CUSTO_OPER_GERAR position 66;

alter table TBVENDAS
alter CUSTO_OPER_PERCENTUAL position 67;

alter table TBVENDAS
alter CUSTO_OPER_FRETE position 68;

alter table TBVENDAS
alter CUSTO_OPER_OUTROS position 69;




/*------ SYSDBA 19/10/2013 23:19:34 --------*/

ALTER TABLE TBVENDAS DROP CUSTO_OPER_GERAR;




/*------ SYSDBA 20/10/2013 12:55:52 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_atualizar_estoque for tbvendas
active after update position 1
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable reserva integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin

    -- Baixar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Reserva, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , reserva
        , valor_produto
    do
    begin
      reserva = :reserva - :Quantidade;
      estoque = :Estoque - :Quantidade;

      -- Baixar estoque
      Update TBPRODUTO p Set
          p.Reserva = :Reserva
        , p.Qtde    = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TVENDASITENS i Set
        i.Qtdefinal = :Estoque
      where i.Ano        = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - VENDA'
        , Current_time
        , :Estoque + :Quantidade
        , :Quantidade
        , :Estoque
        , new.Usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );
    end
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 20/10/2013 12:56:32 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_cancelar for tbvendas
active after update position 2
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 5)) then /* 5. Cancelada */
  begin

    -- Retornar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , valor_produto
    do
    begin
      estoque = :Estoque + :Quantidade;

      -- Retornar estoque
      Update TBPRODUTO p Set
        p.Qtde = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - VENDA CANCELADA'
        , Current_time
        , :Estoque - :Quantidade
        , :Quantidade
        , :Estoque
        , new.Cancel_usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );

    end

    -- Cancelar Contas A Receber (Apenas parcelas nao pagas)
    Update TBCONTREC r Set
        r.status   = 'CANCELADA'
      , r.Situacao = 0 -- Cancelado
      , r.enviado  = 0 -- Enviar boleto novamente para o banco
    where r.anovenda = new.ano
      and r.numvenda = new.codcontrol
      and coalesce(r.Valorrectot, 0) = 0;

    -- Cancelar Movimento Caixa
    Update TBCAIXA_MOVIMENTO m Set
      m.Situacao = 0 -- Cancelado
    where m.Empresa = new.Codemp
      and m.Cliente = new.Codcli
      and m.Venda_ano = new.Ano
      and m.Venda_num = new.Codcontrol;
     
  end 
end^

SET TERM ; ^




/*------ SYSDBA 20/10/2013 13:02:53 --------*/

SET TERM ^ ;

CREATE trigger tg_vendas_custo_operacional for tbvendas
active before update position 3
AS
  declare variable gerar_custo_oper      Smallint;
  declare variable custo_oper_percentual Smallint;
  declare variable custo_oper_frete      Numeric(15,4);
  declare variable custo_oper_outros     Numeric(15,4);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    /* Buscar FLAG de controle */
    Select
      coalesce(c.custo_oper_calcular, 0)
    from TBCONFIGURACAO c
    where c.empresa = new.codemp
    Into
      gerar_custo_oper;

    /* Buscar valores para calculo de custo operacional caso a empresa esteja configurada para este processo */
    if ( :gerar_custo_oper = 1 ) then
    begin
      Select First 1
          c.custo_oper_percentual
        , c.custo_oper_frete
        , c.custo_oper_outros
      from TBCLIENTE c
      where c.cnpj = new.codcli
      Into
          custo_oper_percentual
        , custo_oper_frete
        , custo_oper_outros;

      new.custo_oper_percentual = :custo_oper_percentual;
      new.custo_oper_frete      = :custo_oper_frete;
      new.custo_oper_outros     = :custo_oper_outros;
    end 
  end
end^

SET TERM ; ^

/*------ SYSDBA 20/10/2013 13:02:53 --------*/


ALTER TABLE TBCONFIGURACAO ADD PERMITIR_VENDA_ESTOQUE_INF DMN_LOGICO DEFAULT 0;

DESCRIBE FIELD PERMITIR_VENDA_ESTOQUE_INS TABLE TBCONFIGURACAO
'Permitir vendas de produtos com estoque insuficiente e/ou zerado:
0 - Nao
1 - Sim';

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMPRESA POSITION 1;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONTA POSITION 2;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SENHA POSITION 3;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_POP POSITION 4;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP POSITION 5;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP_PORTA POSITION 6;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_REQUER_AUTENTICACAO POSITION 7;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONEXAO_SSL POSITION 8;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_ASSUNTO_PADRAO POSITION 9;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_MENSAGEM_PADRAO POSITION 10;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_SOLICITA_DH_SAIDA POSITION 11;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_IMPRIMIR_COD_CLIENTE POSITION 12;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR POSITION 13;

ALTER TABLE TBCONFIGURACAO ALTER COLUMN PERMITIR_VENDA_ESTOQUE_INS POSITION 14;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ADD PERMITIR_VENDA_ESTOQUE_INS DMN_LOGICO DEFAULT 0;

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_CLIENTE_CUSTO_OPER
 AS Declare variable I integer;
BEGIN I = 0; END^

/*------ 21/10/2013 20:18:26 --------*/

ALTER TRIGGER TG_VENDAS_CUSTO_OPERACIONAL
 AS Declare variable I integer;
BEGIN I = 0; END^

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ; ^

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR TYPE DMN_LOGICO;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO DROP PERMITIR_VENDA_ESTOQUE_INF;

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_CLIENTE_CUSTO_OPER
AS
  declare variable empresa Varchar(18);
begin
  if ( (new.custo_oper_frete > 0.0) or (new.custo_oper_outros > 0.0) ) then
    for
      Select distinct
          v.codemp
      from TBVENDAS v
        inner join TBCLIENTE c on (c.cnpj = v.codcli)
        inner join TBCONFIGURACAO f on (f.empresa = v.codemp)
      where f.custo_oper_calcular = 1
        and v.ano    = extract(Year from current_date)
        and v.codcli = new.cnpj
        and ((v.custo_oper_frete is null) or (v.custo_oper_outros is null))
      Into
          empresa
    do
    begin

      Update TBVENDAS vd Set
          vd.custo_oper_percentual = new.custo_oper_percentual
        , vd.custo_oper_frete      = new.custo_oper_frete
        , vd.custo_oper_outros     = new.custo_oper_outros
      where vd.ano = extract(Year from current_date)
        and ((vd.custo_oper_frete is null) or (vd.custo_oper_outros is null))
        and vd.codemp = :empresa
        and vd.codcli = new.cnpj;

    end
end^

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ; ^

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_VENDAS_CUSTO_OPERACIONAL
AS
  declare variable gerar_custo_oper      Smallint;
  declare variable custo_oper_percentual Smallint;
  declare variable custo_oper_frete      Numeric(15,4);
  declare variable custo_oper_outros     Numeric(15,4);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    /* Buscar FLAG de controle */
    Select
      coalesce(c.custo_oper_calcular, 0)
    from TBCONFIGURACAO c
    where c.empresa = new.codemp
    Into
      gerar_custo_oper;

    /* Buscar valores para calculo de custo operacional caso a empresa esteja configurada para este processo */
    if ( :gerar_custo_oper = 1 ) then
    begin
      Select First 1
          c.custo_oper_percentual
        , c.custo_oper_frete
        , c.custo_oper_outros
      from TBCLIENTE c
      where c.cnpj = new.codcli
      Into
          custo_oper_percentual
        , custo_oper_frete
        , custo_oper_outros;

      new.custo_oper_percentual = :custo_oper_percentual;
      new.custo_oper_frete      = :custo_oper_frete;
      new.custo_oper_outros     = :custo_oper_outros;
    end 
  end
end^

/*------ 21/10/2013 20:18:26 --------*/

SET TERM ; ^

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMPRESA POSITION 1;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONTA POSITION 2;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SENHA POSITION 3;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_POP POSITION 4;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP POSITION 5;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP_PORTA POSITION 6;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_REQUER_AUTENTICACAO POSITION 7;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONEXAO_SSL POSITION 8;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_ASSUNTO_PADRAO POSITION 9;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_MENSAGEM_PADRAO POSITION 10;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_SOLICITA_DH_SAIDA POSITION 11;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_IMPRIMIR_COD_CLIENTE POSITION 12;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR POSITION 13;

/*------ 21/10/2013 20:18:26 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN PERMITIR_VENDA_ESTOQUE_INS POSITION 14;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ADD USUARIO DMN_VCHAR_50;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBEMPRESA ADD USUARIO DMN_VCHAR_50;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMPRESA POSITION 1;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONTA POSITION 2;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SENHA POSITION 3;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_POP POSITION 4;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP POSITION 5;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP_PORTA POSITION 6;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_REQUER_AUTENTICACAO POSITION 7;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONEXAO_SSL POSITION 8;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_ASSUNTO_PADRAO POSITION 9;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_MENSAGEM_PADRAO POSITION 10;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_SOLICITA_DH_SAIDA POSITION 11;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_IMPRIMIR_COD_CLIENTE POSITION 12;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR POSITION 13;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN PERMITIR_VENDA_ESTOQUE_INS POSITION 14;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN USUARIO POSITION 15;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CODIGO POSITION 1;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN PESSOA_FISICA POSITION 2;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CNPJ POSITION 3;

/*------ 21/10/2013 20:31:07 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN RZSOC POSITION 4;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN NMFANT POSITION 5;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN IE POSITION 6;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN IM POSITION 7;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN SEGMENTO POSITION 8;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CNAE POSITION 9;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN ENDER POSITION 10;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN COMPLEMENTO POSITION 11;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN BAIRRO POSITION 12;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CEP POSITION 13;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CIDADE POSITION 14;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN UF POSITION 15;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN FONE POSITION 16;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN FONE2 POSITION 17;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN LOGO POSITION 18;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN TLG_TIPO POSITION 19;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN LOG_COD POSITION 20;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN BAI_COD POSITION 21;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CID_COD POSITION 22;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN EST_COD POSITION 23;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN NUMERO_END POSITION 24;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN EMAIL POSITION 25;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN HOME_PAGE POSITION 26;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN CHAVE_ACESSO_NFE POSITION 27;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN PAIS_ID POSITION 28;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN TIPO_REGIME_NFE POSITION 29;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN SERIE_NFE POSITION 30;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN NUMERO_NFE POSITION 31;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN LOTE_ANO_NFE POSITION 32;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN LOTE_NUM_NFE POSITION 33;

/*------ 21/10/2013 20:31:08 --------*/

ALTER TABLE TBEMPRESA ALTER COLUMN USUARIO POSITION 34;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ADD ENTREGA_FRACIONADA_VENDA DMN_LOGICO DEFAULT 0;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCONFIGURACAO ADD ESTOQUE_UNICO_EMPRESAS DMN_LOGICO DEFAULT 0;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBFORMPAGTO ADD FORMAPAGTO_NFCE DMN_VCHAR_02 DEFAULT '99';

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBPRODUTO ADD CODIGO_NVE DMN_VCHAR_10;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBVENDAS ADD GERAR_ESTOQUE_CLIENTE DMN_LOGICO DEFAULT 0;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN NCM_SH TYPE DMN_VCHAR_10;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CODIGO POSITION 1;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN PESSOA_FISICA POSITION 2;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CNPJ POSITION 3;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN NOME POSITION 4;

/*------ 22/10/2013 13:57:17 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN INSCEST POSITION 5;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN INSCMUN POSITION 6;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN ENDER POSITION 7;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN COMPLEMENTO POSITION 8;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BAIRRO POSITION 9;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CEP POSITION 10;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CIDADE POSITION 11;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN UF POSITION 12;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN FONE POSITION 13;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN FONECEL POSITION 14;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN FONECOMERC POSITION 15;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN EMAIL POSITION 16;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN SITE POSITION 17;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN TLG_TIPO POSITION 18;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN LOG_COD POSITION 19;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BAI_COD POSITION 20;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CID_COD POSITION 21;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN EST_COD POSITION 22;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN NUMERO_END POSITION 23;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN PAIS_ID POSITION 24;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN VALOR_LIMITE_COMPRA POSITION 25;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BLOQUEADO POSITION 26;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BLOQUEADO_DATA POSITION 27;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BLOQUEADO_MOTIVO POSITION 28;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN BLOQUEADO_USUARIO POSITION 29;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN DESBLOQUEADO_DATA POSITION 30;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN DTCAD POSITION 31;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN VENDEDOR_COD POSITION 32;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN USUARIO POSITION 33;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN EMITIR_NFE_DEVOLUCAO POSITION 34;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CUSTO_OPER_PERCENTUAL POSITION 35;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CUSTO_OPER_FRETE POSITION 36;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN CUSTO_OPER_OUTROS POSITION 37;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCLIENTE ALTER COLUMN ENTREGA_FRACIONADA_VENDA POSITION 38;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMPRESA POSITION 1;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONTA POSITION 2;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SENHA POSITION 3;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_POP POSITION 4;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP POSITION 5;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP_PORTA POSITION 6;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_REQUER_AUTENTICACAO POSITION 7;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONEXAO_SSL POSITION 8;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_ASSUNTO_PADRAO POSITION 9;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_MENSAGEM_PADRAO POSITION 10;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_SOLICITA_DH_SAIDA POSITION 11;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_IMPRIMIR_COD_CLIENTE POSITION 12;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR POSITION 13;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN PERMITIR_VENDA_ESTOQUE_INS POSITION 14;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN ESTOQUE_UNICO_EMPRESAS POSITION 15;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN USUARIO POSITION 16;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN COD POSITION 1;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN DESCRI POSITION 2;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN ACRESCIMO POSITION 3;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN CONTA_CORRENTE POSITION 4;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN DEBITAR_LIMITE_CLIENTE POSITION 5;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBFORMPAGTO ALTER COLUMN FORMAPAGTO_NFCE POSITION 6;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODIGO POSITION 1;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN COD POSITION 2;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN DESCRI POSITION 3;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN APRESENTACAO POSITION 4;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN DESCRI_APRESENTACAO POSITION 5;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN MODELO POSITION 6;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PRECO POSITION 7;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PRECO_PROMOCAO POSITION 8;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN REFERENCIA POSITION 9;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN SECAO POSITION 10;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN QTDE POSITION 11;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN FRACIONADOR POSITION 12;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PESO_BRUTO POSITION 13;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PESO_LIQUIDO POSITION 14;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CUBAGEM POSITION 15;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN VENDA_FRACIONADA POSITION 16;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODUNIDADE_FRACIONADA POSITION 17;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN UNIDADE POSITION 18;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ESTOQMIN POSITION 19;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODGRUPO POSITION 20;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODFABRICANTE POSITION 21;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CUSTOMEDIO POSITION 22;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PERCENTUAL_MARCKUP POSITION 23;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PERCENTUAL_MARGEM POSITION 24;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PRECO_SUGERIDO POSITION 25;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODEMP POSITION 26;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODSECAO POSITION 27;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODORIGEM POSITION 28;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODTRIBUTACAO POSITION 29;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CST POSITION 30;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CSOSN POSITION 31;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CST_PIS POSITION 32;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CST_COFINS POSITION 33;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN NCM_SH POSITION 34;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODIGO_NVE POSITION 35;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODCFOP POSITION 36;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODBARRA_EAN POSITION 37;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CODUNIDADE POSITION 38;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ALIQUOTA_TIPO POSITION 39;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ALIQUOTA POSITION 40;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ALIQUOTA_CSOSN POSITION 41;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ALIQUOTA_PIS POSITION 42;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ALIQUOTA_COFINS POSITION 43;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN VALOR_IPI POSITION 44;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN RESERVA POSITION 45;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PRODUTO_NOVO POSITION 46;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN COR_VEICULO POSITION 47;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN COMBUSTIVEL_VEICULO POSITION 48;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN TIPO_VEICULO POSITION 49;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ANO_MODELO_VEICULO POSITION 50;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN ANO_FABRICACAO_VEICULO POSITION 51;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN RENAVAM_VEICULO POSITION 52;

/*------ 22/10/2013 13:57:18 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN CHASSI_VEICULO POSITION 53;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN KILOMETRAGEM_VEICULO POSITION 54;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN SITUACAO_ATUAL_VEICULO POSITION 55;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN SITUACAO_HISTORICO_VEICULO POSITION 56;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN PERCENTUAL_REDUCAO_BC POSITION 57;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBPRODUTO ALTER COLUMN USUARIO POSITION 58;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN ANO POSITION 1;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODCONTROL POSITION 2;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODEMP POSITION 3;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODCLI POSITION 4;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DTVENDA POSITION 5;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN STATUS POSITION 6;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALVENDA_BRUTA POSITION 7;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DESCONTO POSITION 8;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALVENDA POSITION 9;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALCUSTO POSITION 10;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DTFINALIZACAO_VENDA POSITION 11;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN OBS POSITION 12;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FORMAPAG POSITION 13;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FATDIAS POSITION 14;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN SERIE POSITION 15;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE POSITION 16;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DATAEMISSAO POSITION 17;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN HORAEMISSAO POSITION 18;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CFOP POSITION 19;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VERIFICADOR_NFE POSITION 20;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN XML_NFE POSITION 21;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VENDEDOR_COD POSITION 22;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN USUARIO POSITION 23;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FORMAPAGTO_COD POSITION 24;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CONDICAOPAGTO_COD POSITION 25;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VENDA_PRAZO POSITION 26;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_01 POSITION 27;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_02 POSITION 28;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_03 POSITION 29;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_04 POSITION 30;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_05 POSITION 31;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_06 POSITION 32;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_07 POSITION 33;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_08 POSITION 34;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_09 POSITION 35;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_10 POSITION 36;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_11 POSITION 37;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_12 POSITION 38;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_ANO POSITION 39;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_NUMERO POSITION 40;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_RECIBO POSITION 41;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_ENVIADA POSITION 42;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_USUARIO POSITION 43;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_DATAHORA POSITION 44;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_MOTIVO POSITION 45;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN XML_NFE_FILENAME POSITION 46;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_MODALIDADE_FRETE POSITION 47;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_TRANSPORTADORA POSITION 48;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_VEICULO POSITION 49;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_UF POSITION 50;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_RNTC POSITION 51;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_BASE_ICMS POSITION 52;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_ICMS POSITION 53;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_BASE_ICMS_SUBST POSITION 54;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_ICMS_SUBST POSITION 55;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_PRODUTO POSITION 56;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_FRETE POSITION 57;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_SEGURO POSITION 58;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_DESCONTO POSITION 59;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_II POSITION 60;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_IPI POSITION 61;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_PIS POSITION 62;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_COFINS POSITION 63;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_OUTROS POSITION 64;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_NOTA POSITION 65;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_PERCENTUAL POSITION 66;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_FRETE POSITION 67;

/*------ 22/10/2013 13:57:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_OUTROS POSITION 68;

/*------ 22/10/2013 13:57:20 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN GERAR_ESTOQUE_CLIENTE POSITION 69;

/*------ 24/10/2013 19:26:12 --------*/

CREATE VIEW VW_FORMA_PAGTO_NFC_E(
CODIGO,
DESCRICAO)
 AS 
Select first 1 '01' as codigo, 'Dinheiro' as descricao          from TBEMPRESA union
Select first 1 '02' as codigo, 'Cheque' as descricao            from TBEMPRESA union
Select first 1 '03' as codigo, 'Cartao de Credito' as descricao from TBEMPRESA union
Select first 1 '04' as codigo, 'Cartao de Debito' as descricao  from TBEMPRESA union
Select first 1 '05' as codigo, 'Credito Loja' as descricao      from TBEMPRESA union
Select first 1 '10' as codigo, 'Vale Alimentacao' as descricao  from TBEMPRESA union
Select first 1 '11' as codigo, 'Vale Refeicao' as descricao     from TBEMPRESA union
Select first 1 '12' as codigo, 'Vale Presente' as descricao     from TBEMPRESA union
Select first 1 '13' as codigo, 'Vale Combustivel' as descricao  from TBEMPRESA union
Select first 1 '99' as codigo, 'Outros' as descricao            from TBEMPRESA;

/*------ 24/10/2013 19:26:13 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_VENDAS_ATUALIZAR_ESTOQUE
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable reserva integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin

    -- Baixar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Reserva, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , reserva
        , valor_produto
    do
    begin
      reserva = 0; -- :reserva - :Quantidade;  -- Descontinuada RESERVA
      estoque = :Estoque - :Quantidade;

      -- Baixar estoque
      Update TBPRODUTO p Set
          p.Reserva = :Reserva
        , p.Qtde    = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gravar posicao de estoque
      Update TVENDASITENS i Set
        i.Qtdefinal = :Estoque
      where i.Ano        = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - VENDA'
        , Current_time
        , :Estoque + :Quantidade
        , :Quantidade
        , :Estoque
        , new.Usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );
    end
     
  end 
end^

/*------ 24/10/2013 19:26:13 --------*/

SET TERM ; ^

GRANT ALL ON TBPRODUTO_ROTATIVIDADE TO PUBLIC;

/*------ 24/10/2013 19:26:13 --------*/

GRANT ALL ON VW_FORMA_PAGTO_NFC_E TO PUBLIC;

/*------ 24/10/2013 19:26:13 --------*/

GRANT ALL ON VW_FORMA_PAGTO_NFC_E TO SYSDBA WITH GRANT OPTION;

/*------ 24/10/2013 19:26:13 --------*/

GRANT ALL ON VW_LAYOUT_REM_RET_BANCO TO PUBLIC;

/*------ 26/10/2013 17:20:46 --------*/

ALTER TABLE TBCFOP ADD CFOP_ALTERA_CUSTO_PRODUTO DMN_LOGICO DEFAULT 1;

/*------ 26/10/2013 17:20:47 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_COMPRAS_ATUALIZAR_ESTOQUE
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable custo_produto numeric(15,2);
  declare variable custo_compra numeric(15,2);
  declare variable custo_medio numeric(15,2);
  declare variable preco_venda dmn_money;
  declare variable percentual_markup dmn_percentual_3;
  declare variable alterar_custo Smallint;
  declare variable estoque_unico Smallint;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 2)) then
  begin

    -- Buscar FLAG de alteracao de custo de produto
    Select
      cf.cfop_altera_custo_produto
    from TBCFOP cf
    where cf.cfop_cod = new.nfcfop
    Into
        alterar_custo;

    alterar_custo = coalesce(:alterar_custo, 1);

    -- Buscar FLAG de estoque unico
    Select
      cnf.estoque_unico_empresas
    from TBCONFIGURACAO cnf
    where cnf.empresa = new.codemp
    Into
      estoque_unico;

    estoque_unico = coalesce(:estoque_unico, 0);

    -- Incrimentar Estoque do produto
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(i.Customedio, 0)
        , coalesce(p.Customedio, 0)
        , p.percentual_marckup
        , p.preco
      from TBCOMPRASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          Produto
        , Empresa
        , Quantidade
        , Estoque
        , Custo_compra
        , Custo_produto
        , Percentual_markup
        , Preco_venda
    do
    begin
      if ( (:Custo_compra > 0) and (:Custo_produto > 0) and (:Estoque > 0) ) then
        Custo_medio = (:Custo_compra + :Custo_produto) / 2;
      else
        Custo_medio = :Custo_compra;

--      Percentual_markup = cast( ( ( (:Preco_venda - :Custo_medio) / :Custo_medio) * 100) as numeric(18,3) );
      Percentual_markup = cast( ( ( (:Preco_venda - :Custo_compra) / :Custo_compra) * 100 ) as numeric(18,3) );

      -- Incrementar estoque
      Update TBPRODUTO p Set
          --p.Customedio = Case when :alterar_custo = 1 then :Custo_medio else p.Customedio end
          p.Customedio = Case when :alterar_custo = 1 then :Custo_compra else p.Customedio end
        , p.Qtde       = :Estoque + :Quantidade
        , p.percentual_marckup = :Percentual_markup
--        , p.preco_sugerido     = cast( (:Custo_medio + (:Custo_medio * :Percentual_markup / 100)) as numeric(15,2) )
        , p.preco_sugerido     = cast( (:Custo_compra + (:Custo_compra * :Percentual_markup / 100)) as numeric(15,2) )
      where (p.Cod     = :Produto)
        and ((p.Codemp = :Empresa) or (:estoque_unico = 1)) ;

      -- Gravar posicao de estoque
      Update TBCOMPRASITENS i Set
          i.Qtdeantes = :Estoque
        , i.Qtdefinal = :Estoque + :Quantidade
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - COMPRA'
        , Current_time
        , :Estoque
        , :Quantidade
        , :Estoque + :Quantidade
        , new.Usuario
        , 'Custo Medio no valor de R$ ' || :Custo_medio
      );
    end
     
  end 
end^

/*------ 26/10/2013 17:20:47 --------*/

ALTER TRIGGER TG_VENDAS_ATUALIZAR_ESTOQUE
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable reserva integer;
  declare variable valor_produto numeric(15,2);
  declare variable estoque_unico Smallint;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin

    -- Buscar FLAG de estoque unico
    Select
      cnf.estoque_unico_empresas
    from TBCONFIGURACAO cnf
    where cnf.empresa = new.codemp
    Into
      estoque_unico;
    estoque_unico = coalesce(:estoque_unico, 0);

    -- Baixar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Reserva, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , reserva
        , valor_produto
    do
    begin
      reserva = 0; -- :reserva - :Quantidade;  -- Descontinuada RESERVA
      estoque = :Estoque - :Quantidade;

      -- Baixar estoque
      Update TBPRODUTO p Set
          p.Qtde    = :Estoque
        --, p.Reserva = :Reserva               -- Descontinuada RESERVA
      where (p.Cod     = :Produto)
        and ((p.Codemp = :Empresa) or (:estoque_unico = 1)) ;

      -- Gravar posicao de estoque
      Update TVENDASITENS i Set
        i.Qtdefinal = :Estoque
      where i.Ano        = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - VENDA'
        , Current_time
        , :Estoque + :Quantidade
        , :Quantidade
        , :Estoque
        , new.Usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );
    end
     
  end 
end^

/*------ 26/10/2013 17:20:47 --------*/

SET TERM ; ^

DROP TRIGGER TG_VENDASITENS_RESERVAR;

/*------ 26/10/2013 17:20:47 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_VENDASITENS_RESERVAR FOR TVENDASITENS
INACTIVE AFTER INSERT OR UPDATE OR DELETE POSITION 1 
AS
  --declare variable status_venda Smallint;
  declare variable reserva integer;
begin
  /*
  Select
    v.Status
  from TBVENDAS v
  where v.Ano = new.Ano
    and v.Codcontrol = new.Codcontrol
  into
    status_venda;
  */

  Exit; -- Descontinuada RESERVA

  if ( Inserting or Updating  ) then
  begin
      Select
         coalesce(p.Reserva, 0) - coalesce(old.Qtde, 0) + coalesce(new.Qtde, 0)
      from TBPRODUTO p
      where p.Cod    = new.Codprod
        and p.Codemp = new.Codemp
      into
        Reserva;
  end

  else

  if ( Deleting  ) then
  begin
      Select
         coalesce(p.Reserva, 0) - coalesce(old.Qtde, 0)
      from TBPRODUTO p
      where p.Cod    = old.Codprod
        and p.Codemp = old.Codemp
      into
        Reserva;
  end

  Update TBPRODUTO Set
    Reserva = :Reserva
  where Cod    = new.Codprod
    and Codemp = new.Codemp;
end^

/*------ 26/10/2013 17:20:47 --------*/

SET TERM ; ^

ALTER TABLE TBCFOP ALTER COLUMN CFOP_COD POSITION 1;

/*------ 26/10/2013 17:20:47 --------*/

ALTER TABLE TBCFOP ALTER COLUMN CFOP_DESCRICAO POSITION 2;

/*------ 26/10/2013 17:20:47 --------*/

ALTER TABLE TBCFOP ALTER COLUMN CFOP_ESPECIFICACAO POSITION 3;

/*------ 26/10/2013 17:20:47 --------*/

ALTER TABLE TBCFOP ALTER COLUMN CFOP_ALTERA_CUSTO_PRODUTO POSITION 4;

/*------ 26/10/2013 18:51:18 --------*/

DROP TRIGGER TG_VENDAS_ATUALIZAR_ESTOQUE;

/*------ 26/10/2013 18:51:18 --------*/

CREATE TABLE TBCLIENTE_ESTOQUE(COD_CLIENTE DMN_CNPJ NOT NULL,
COD_PRODUTO VARCHAR(10) NOT NULL,
QUANTIDADE INTEGER,
USUARIO VARCHAR(50),
ANO_VENDA_ULT DMN_SMALLINT_N,
COD_VENDA_ULT DMN_INTEGER_N);

/*------ 26/10/2013 18:51:18 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ADD CONSTRAINT PK_TBCLIENTE_ESTOQUE PRIMARY KEY (COD_CLIENTE, COD_PRODUTO);

/*------ 26/10/2013 18:51:18 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ADD CONSTRAINT FK_TBCLIENTE_ESTOQUE_CLI FOREIGN KEY (COD_CLIENTE) REFERENCES TBCLIENTE (CNPJ);

/*------ 26/10/2013 18:51:18 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ADD CONSTRAINT FK_TBCLIENTE_ESTOQUE_PRD FOREIGN KEY (COD_PRODUTO) REFERENCES TBPRODUTO (COD);

/*------ 26/10/2013 18:51:18 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ADD CONSTRAINT FK_TBCLIENTE_ESTOQUE_VND FOREIGN KEY (ANO_VENDA_ULT, COD_VENDA_ULT) REFERENCES TBVENDAS (ANO, CODCONTROL);

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_VENDAS_ESTOQUE_ATUALIZAR FOR TBVENDAS
ACTIVE AFTER UPDATE POSITION 1 
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable reserva integer;
  declare variable valor_produto numeric(15,2);
  declare variable estoque_unico Smallint;
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin

    -- Buscar FLAG de estoque unico
    Select
      cnf.estoque_unico_empresas
    from TBCONFIGURACAO cnf
    where cnf.empresa = new.codemp
    Into
      estoque_unico;
    estoque_unico = coalesce(:estoque_unico, 0);

    -- Baixar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Reserva, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , reserva
        , valor_produto
    do
    begin
      reserva = 0; -- :reserva - :Quantidade;  -- Descontinuada RESERVA
      estoque = :Estoque - :Quantidade;

      -- Baixar estoque
      Update TBPRODUTO p Set
          p.Qtde    = :Estoque
        --, p.Reserva = :Reserva               -- Descontinuada RESERVA
      where (p.Cod     = :Produto)
        and ((p.Codemp = :Empresa) or (:estoque_unico = 1)) ;

      -- Gravar posicao de estoque
      Update TVENDASITENS i Set
        i.Qtdefinal = :Estoque
      where i.Ano        = new.Ano
        and i.Codcontrol = new.Codcontrol
        and i.Codemp     = new.Codemp
        and i.Codprod    = :Produto;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'SAIDA - VENDA'
        , Current_time
        , :Estoque + :Quantidade
        , :Quantidade
        , :Estoque
        , new.Usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );
    end
     
  end 
end^

/*------ 26/10/2013 18:51:18 --------*/

CREATE TRIGGER TG_VENDAS_ESTOQUE_CLIENTE FOR TBVENDAS
ACTIVE AFTER UPDATE POSITION 0 
AS
  declare variable produto varchar(10);
  declare variable quantidade integer;
  declare variable estoque integer;
begin

  /* Gerar Estoque para o Cliente na Finalizacao da Venda */

  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida
          , coalesce(c.quantidade, 0) -- Estoque
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
      do
      begin

        if (not exists(
          Select
            ec.cod_cliente
          from TBCLIENTE_ESTOQUE ec
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto
        )) then
        begin

          -- Gerar Estoque
          Insert Into TBCLIENTE_ESTOQUE (
              cod_cliente
            , cod_produto
            , quantidade
            , usuario
            , ano_venda_ult
            , cod_venda_ult
          ) values (
              new.codcli
            , :produto
            , :quantidade
            , new.usuario
            , new.ano
            , new.codcontrol
          );

        end
        else
        begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
            ec.quantidade = coalesce(:quantidade, 0) + coalesce(:estoque, 0)
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

        end 

      end 

    end
  end

  else

  /* Atualizar Estoque do Cliente no Cancelamento da Venda */

  if ( (coalesce(old.Status, 0) in (3, 4)) and (new.Status = 5)) then /* 5. Cancelada */
  begin

    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida cancelada
          , coalesce(c.quantidade, 0) -- Estoque
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
      do
      begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
            ec.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0)
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

      end

    end

  end

end^

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ; ^

/*------ 26/10/2013 18:51:18 --------*/

DROP TRIGGER TG_VENDAS_CANCELAR;

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_VENDAS_CANCELAR FOR TBVENDAS
ACTIVE AFTER UPDATE POSITION 3 
AS
  declare variable produto varchar(10);
  declare variable empresa varchar(18);
  declare variable estoque integer;
  declare variable quantidade integer;
  declare variable valor_produto numeric(15,2);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 5)) then /* 5. Cancelada */
  begin

    -- Retornar produto do Estoque
    for
      Select
          i.Codprod
        , i.Codemp
        , i.Qtde
        , coalesce(p.Qtde, 0)
        , coalesce(p.Preco, 0)
      from TVENDASITENS i
        inner join TBPRODUTO p on (p.Cod = i.Codprod)
      where i.Ano = new.Ano
        and i.Codcontrol = new.Codcontrol
      into
          produto
        , empresa
        , quantidade
        , estoque
        , valor_produto
    do
    begin
      estoque = :Estoque + :Quantidade;

      -- Retornar estoque
      Update TBPRODUTO p Set
        p.Qtde = :Estoque
      where p.Cod    = :Produto
        and p.Codemp = :Empresa;

      -- Gerar historico
      Insert Into TBPRODHIST (
          Codempresa
        , Codprod
        , Doc
        , Historico
        , Dthist
        , Qtdeatual
        , Qtdenova
        , Qtdefinal
        , Resp
        , Motivo
      ) values (
          :Empresa
        , :Produto
        , new.Ano || '/' || new.Codcontrol
        , 'ENTRADA - VENDA CANCELADA'
        , Current_time
        , :Estoque - :Quantidade
        , :Quantidade
        , :Estoque
        , new.Cancel_usuario
        , 'Venda no valor de R$ ' || :Valor_produto
      );

    end

    -- Cancelar Contas A Receber (Apenas parcelas nao pagas)
    Update TBCONTREC r Set
        r.status   = 'CANCELADA'
      , r.Situacao = 0 -- Cancelado
      , r.enviado  = 0 -- Enviar boleto novamente para o banco
    where r.anovenda = new.ano
      and r.numvenda = new.codcontrol
      and coalesce(r.Valorrectot, 0) = 0;

    -- Cancelar Movimento Caixa
    Update TBCAIXA_MOVIMENTO m Set
      m.Situacao = 0 -- Cancelado
    where m.Empresa = new.Codemp
      and m.Cliente = new.Codcli
      and m.Venda_ano = new.Ano
      and m.Venda_num = new.Codcontrol;
     
  end 
end^

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ; ^

DROP TRIGGER TG_VENDAS_CUSTO_OPERACIONAL;

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_VENDAS_CUSTO_OPERACIONAL FOR TBVENDAS
ACTIVE BEFORE UPDATE POSITION 4 
AS
  declare variable gerar_custo_oper      Smallint;
  declare variable custo_oper_percentual Smallint;
  declare variable custo_oper_frete      Numeric(15,4);
  declare variable custo_oper_outros     Numeric(15,4);
begin
  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    /* Buscar FLAG de controle */
    Select
      coalesce(c.custo_oper_calcular, 0)
    from TBCONFIGURACAO c
    where c.empresa = new.codemp
    Into
      gerar_custo_oper;

    /* Buscar valores para calculo de custo operacional caso a empresa esteja configurada para este processo */
    if ( :gerar_custo_oper = 1 ) then
    begin
      Select First 1
          c.custo_oper_percentual
        , c.custo_oper_frete
        , c.custo_oper_outros
      from TBCLIENTE c
      where c.cnpj = new.codcli
      Into
          custo_oper_percentual
        , custo_oper_frete
        , custo_oper_outros;

      new.custo_oper_percentual = :custo_oper_percentual;
      new.custo_oper_frete      = :custo_oper_frete;
      new.custo_oper_outros     = :custo_oper_outros;
    end 
  end
end^

/*------ 26/10/2013 18:51:18 --------*/

SET TERM ; ^

GRANT ALL ON TBCLIENTE_ESTOQUE TO PUBLIC;

/*------ 26/10/2013 18:51:18 --------*/

GRANT ALL ON TBCLIENTE_ESTOQUE TO SYSDBA WITH GRANT OPTION;


/*------ SYSDBA 26/10/2013 18:53:05 --------*/

SET TERM ^ ;

CREATE OR ALTER trigger tg_vendas_estoque_cliente for tbvendas
active after update position 2
AS
  declare variable produto varchar(10);
  declare variable quantidade integer;
  declare variable estoque integer;
begin

  /* Gerar Estoque para o Cliente na Finalizacao da Venda */

  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida
          , coalesce(c.quantidade, 0) -- Estoque
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
      do
      begin

        if (not exists(
          Select
            ec.cod_cliente
          from TBCLIENTE_ESTOQUE ec
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto
        )) then
        begin

          -- Gerar Estoque
          Insert Into TBCLIENTE_ESTOQUE (
              cod_cliente
            , cod_produto
            , quantidade
            , usuario
            , ano_venda_ult
            , cod_venda_ult
          ) values (
              new.codcli
            , :produto
            , :quantidade
            , new.usuario
            , new.ano
            , new.codcontrol
          );

        end
        else
        begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
            ec.quantidade = coalesce(:quantidade, 0) + coalesce(:estoque, 0)
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

        end 

      end 

    end
  end

  else

  /* Atualizar Estoque do Cliente no Cancelamento da Venda */

  if ( (coalesce(old.Status, 0) in (3, 4)) and (new.Status = 5)) then /* 5. Cancelada */
  begin

    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida cancelada
          , coalesce(c.quantidade, 0) -- Estoque
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
      do
      begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
            ec.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0)
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

      end

    end

  end

end^

SET TERM ; ^



/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ADD ESTOQUE_SATELITE_CLIENTE DMN_LOGICO DEFAULT 0;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMPRESA POSITION 1;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONTA POSITION 2;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SENHA POSITION 3;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_POP POSITION 4;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP POSITION 5;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_SMTP_PORTA POSITION 6;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_REQUER_AUTENTICACAO POSITION 7;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_CONEXAO_SSL POSITION 8;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_ASSUNTO_PADRAO POSITION 9;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN EMAIL_MENSAGEM_PADRAO POSITION 10;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_SOLICITA_DH_SAIDA POSITION 11;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN NFE_IMPRIMIR_COD_CLIENTE POSITION 12;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN CUSTO_OPER_CALCULAR POSITION 13;

/*------ 26/10/2013 19:44:58 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN PERMITIR_VENDA_ESTOQUE_INS POSITION 14;

/*------ 26/10/2013 19:44:59 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN ESTOQUE_UNICO_EMPRESAS POSITION 15;

/*------ 26/10/2013 19:44:59 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN ESTOQUE_SATELITE_CLIENTE POSITION 16;

/*------ 26/10/2013 19:44:59 --------*/

ALTER TABLE TBCONFIGURACAO ALTER COLUMN USUARIO POSITION 17;

/*------ 29/10/2013 11:30:23 --------*/

CREATE TABLE TBCLIENTE_REQUISICAO(ANO DMN_SMALLINT_NN NOT NULL,
NUMERO DMN_INTEGER_NN NOT NULL,
CODCLIENTE DMN_CNPJ NOT NULL,
DATA_MOVIMENTO DMN_DATE,
INSERCAO_DATA DMN_DATE,
INSERCAO_HORA DMN_TIME,
INSERCAO_USUARIO DMN_VCHAR_50,
SITUACAO DMN_SMALLINT_NN DEFAULT 0 NOT NULL,
OBSERVACOES DMN_TEXTO,
AUTORIZACAO_DATA DMN_DATE,
AUTORIZACAO_USUARIO DMN_VCHAR_50,
RECEBEDOR_NOME DMN_VCHAR_50,
RECEBEDOR_RG DMN_RG,
CANCELADO_DATA DMN_DATE,
CANCELADO_MOTIVO DMN_TEXTO);

/*------ 29/10/2013 11:30:23 --------*/

CREATE TABLE TBCLIENTE_REQUISICAO_ITEM(ANO DMN_SMALLINT_NN NOT NULL,
NUMERO DMN_INTEGER_NN NOT NULL,
ITEM DMN_SMALLINT_NN NOT NULL,
CODPRODUTO DMN_VCHAR_10 NOT NULL,
QUANTIDADE DMN_INTEGER_N DEFAULT 1,
UNIDADE DMN_SMALLINT_N,
USUARIO DMN_VCHAR_50);

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBUSERS ADD ATIVO DMN_LOGICO DEFAULT 1;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2011;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2012;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2013;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2014;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2015;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2016;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2017;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2018;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2019;

/*------ 29/10/2013 11:30:24 --------*/

CREATE GENERATOR GEN_REQUISICAO_2020;

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ADD CONSTRAINT PK_TBCLIENTE_REQUISICAO PRIMARY KEY (ANO, NUMERO);

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT PK_TBCLIENTE_REQUISICAO_ITEM PRIMARY KEY (ANO, NUMERO, ITEM);

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT FK_TBCLIENTE_REQ_ITEM_PRD FOREIGN KEY (CODPRODUTO) REFERENCES TBPRODUTO (COD);

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT FK_TBCLIENTE_REQ_ITEM_REQ FOREIGN KEY (ANO, NUMERO) REFERENCES TBCLIENTE_REQUISICAO (ANO, NUMERO) ON UPDATE CASCADE ON DELETE CASCADE;

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT FK_TBCLIENTE_REQ_ITEM_UND FOREIGN KEY (UNIDADE) REFERENCES TBUNIDADEPROD (UNP_COD);

/*------ 29/10/2013 11:30:24 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ADD CONSTRAINT FK_TBCLIENTE_REQUISICAO_CLI FOREIGN KEY (CODCLIENTE) REFERENCES TBCLIENTE (CNPJ);

/*------ 29/10/2013 11:30:24 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_CLIENTE_REQUISICAO_ESTOQUE FOR TBCLIENTE_REQUISICAO
ACTIVE BEFORE UPDATE POSITION 1 
AS
  declare variable produto    Varchar(10);
  declare variable quantidade Integer;
  declare variable estoque    Integer;
begin
  /* 1. AUTORIZADA - Decrementar estoque satelite do cliente quando a requisicao for autorizada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 1) ) then
  begin
    for
      Select
          i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          produto
        , quantidade
        , estoque
    do
    begin

      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0) -- Retirar estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

    end 
  end 

  else

  /* 3. CANCELADA - Incfementar estoque satelite do cliente quando a requisicao for cancelada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 3) ) then
  begin
    for
      Select
          i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          produto
        , quantidade
        , estoque
    do
    begin

      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) + coalesce(:quantidade, 0) -- Devolver estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

    end 
  end
end^

/*------ 29/10/2013 11:30:24 --------*/

SET TERM ; ^

/*------ 29/10/2013 11:30:24 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_CLIENTE_REQUISICAO_ITEM_SEQ FOR TBCLIENTE_REQUISICAO_ITEM
ACTIVE BEFORE INSERT POSITION 0 
AS
begin
  if ( coalesce(new.item, 0) = 0 ) then
    Select
      coalesce(max(i.item), 0) + 1
    from TBCLIENTE_REQUISICAO_ITEM i
    where i.ano    = new.ano
      and i.numero = new.numero
    Into
      new.item;

  if ( new.usuario is null ) then
    new.usuario = user;
end^

/*------ 29/10/2013 11:30:24 --------*/

SET TERM ; ^

/*------ 29/10/2013 11:30:25 --------*/

SET TERM ^ ;

CREATE TRIGGER TG_CLIENTE_REQUISICAO_NOVA FOR TBCLIENTE_REQUISICAO
ACTIVE BEFORE INSERT POSITION 0 
AS
begin
  if ( coalesce(new.ano, 0) = 0 ) then
    new.ano = extract(year from current_date);

  if ( coalesce(new.numero, 0) = 0 ) then
    if ( new.ano = 2011 ) then
      new.numero = gen_id(GEN_REQUISICAO_2011, 1);
    else
    if ( new.ano = 2012 ) then
      new.numero = gen_id(GEN_REQUISICAO_2012, 1);
    else
    if ( new.ano = 2013 ) then
      new.numero = gen_id(GEN_REQUISICAO_2013, 1);
    else
    if ( new.ano = 2014 ) then
      new.numero = gen_id(GEN_REQUISICAO_2014, 1);
    else
    if ( new.ano = 2015 ) then
      new.numero = gen_id(GEN_REQUISICAO_2015, 1);
    else
    if ( new.ano = 2016 ) then
      new.numero = gen_id(GEN_REQUISICAO_2016, 1);
    else
    if ( new.ano = 2017 ) then
      new.numero = gen_id(GEN_REQUISICAO_2017, 1);
    else
    if ( new.ano = 2018 ) then
      new.numero = gen_id(GEN_REQUISICAO_2018, 1);
    else
    if ( new.ano = 2019 ) then
      new.numero = gen_id(GEN_REQUISICAO_2019, 1);
    else
    if ( new.ano = 2020 ) then
      new.numero = gen_id(GEN_REQUISICAO_2020, 1);

  if ( new.insercao_data is null ) then
    new.insercao_data = current_date;

  if ( new.insercao_hora is null ) then
    new.insercao_usuario = current_time;

  if ( new.insercao_usuario is null ) then
    new.insercao_usuario = user;
end^

/*------ 29/10/2013 11:30:25 --------*/

SET TERM ; ^

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOME POSITION 1;

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN SENHA POSITION 2;

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOMECOMPLETO POSITION 3;

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN CODFUNCAO POSITION 4;

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN LIMIDESC POSITION 5;

/*------ 29/10/2013 11:30:25 --------*/

ALTER TABLE TBUSERS ALTER COLUMN ATIVO POSITION 6;

/*------ 29/10/2013 11:30:25 --------*/

GRANT ALL ON TBCLIENTE_REQUISICAO TO PUBLIC;

/*------ 29/10/2013 11:30:25 --------*/

GRANT ALL ON TBCLIENTE_REQUISICAO TO SYSDBA WITH GRANT OPTION;

/*------ 29/10/2013 11:30:25 --------*/

GRANT ALL ON TBCLIENTE_REQUISICAO_ITEM TO PUBLIC;

/*------ 29/10/2013 11:30:25 --------*/

GRANT ALL ON TBCLIENTE_REQUISICAO_ITEM TO SYSDBA WITH GRANT OPTION;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ADD CODEMPRESA DMN_CNPJ;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ADD CONSTRAINT FK_TBCLIENTE_REQUISICAO_EMP FOREIGN KEY (CODEMPRESA) REFERENCES TBEMPRESA (CNPJ);

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN ANO POSITION 1;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN NUMERO POSITION 2;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN CODEMPRESA POSITION 3;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN CODCLIENTE POSITION 4;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN DATA_MOVIMENTO POSITION 5;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN INSERCAO_DATA POSITION 6;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN INSERCAO_HORA POSITION 7;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN INSERCAO_USUARIO POSITION 8;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN SITUACAO POSITION 9;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN OBSERVACOES POSITION 10;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN AUTORIZACAO_DATA POSITION 11;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN AUTORIZACAO_USUARIO POSITION 12;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN RECEBEDOR_NOME POSITION 13;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN RECEBEDOR_RG POSITION 14;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN CANCELADO_DATA POSITION 15;

/*------ 29/10/2013 12:22:25 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO ALTER COLUMN CANCELADO_MOTIVO POSITION 16;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD QUANTIDADE_FINAL DMN_INTEGER_N DEFAULT 0;

/*------ 29/10/2013 14:36:34 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_CLIENTE_REQUISICAO_ESTOQUE
AS
  declare variable item       Smallint;
  declare variable produto    Varchar(10);
  declare variable quantidade Integer;
  declare variable estoque    Integer;
begin
  /* 1. AUTORIZADA - Decrementar estoque satelite do cliente quando a requisicao for autorizada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 1) ) then
  begin
    for
      Select
          i.numero
        , i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          item
        , produto
        , quantidade
        , estoque
    do
    begin

      -- Baixar estoque
      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0) -- Retirar estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

      -- Guardar historico estoque satelite
      Update TBCLIENTE_REQUISICAO_ITEM i Set
        i.quantidade_final = coalesce(:estoque, 0) - coalesce(:quantidade, 0)
      where i.ano    = new.ano
        and i.numero = new.numero
        and i.item   = :item;

    end 
  end 

  else

  /* 3. CANCELADA - Incfementar estoque satelite do cliente quando a requisicao for cancelada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 3) ) then
  begin
    for
      Select
          i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          produto
        , quantidade
        , estoque
    do
    begin

      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) + coalesce(:quantidade, 0) -- Devolver estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

    end 
  end
end^

/*------ 29/10/2013 14:36:34 --------*/

SET TERM ; ^

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ANO POSITION 1;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN NUMERO POSITION 2;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ITEM POSITION 3;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODPRODUTO POSITION 4;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE POSITION 5;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE_FINAL POSITION 6;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN UNIDADE POSITION 7;

/*------ 29/10/2013 14:36:34 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN USUARIO POSITION 8;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CODEMPRESA DMN_CNPJ;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CODCLIENTE DMN_CNPJ;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT FK_TBCLIENTE_REQ_ITEM_CLI FOREIGN KEY (CODCLIENTE) REFERENCES TBCLIENTE (CNPJ);

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD CONSTRAINT FK_TBCLIENTE_REQ_ITEM_EMP FOREIGN KEY (CODEMPRESA) REFERENCES TBEMPRESA (CNPJ);

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ANO POSITION 1;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN NUMERO POSITION 2;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ITEM POSITION 3;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODEMPRESA POSITION 4;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODCLIENTE POSITION 5;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODPRODUTO POSITION 6;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE POSITION 7;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE_FINAL POSITION 8;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN UNIDADE POSITION 9;

/*------ 29/10/2013 14:42:19 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN USUARIO POSITION 10;

/*------ 29/10/2013 15:44:38 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_CLIENTE_REQUISICAO_ESTOQUE
AS
  declare variable item       Smallint;
  declare variable produto    Varchar(10);
  declare variable quantidade Integer;
  declare variable estoque    Integer;
begin
  /* 2. AUTORIZADA - Decrementar estoque satelite do cliente quando a requisicao for autorizada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 2) ) then
  begin
    for
      Select
          i.numero
        , i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          item
        , produto
        , quantidade
        , estoque
    do
    begin

      -- Baixar estoque
      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0) -- Retirar estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

      -- Guardar historico estoque satelite
      Update TBCLIENTE_REQUISICAO_ITEM i Set
        i.quantidade_final = coalesce(:estoque, 0) - coalesce(:quantidade, 0)
      where i.ano    = new.ano
        and i.numero = new.numero
        and i.item   = :item;

    end 
  end 

  else

  /* 4. CANCELADA - Incfementar estoque satelite do cliente quando a requisicao for cancelada  */

  if ( (old.situacao <> new.situacao) and (new.situacao = 4) ) then
  begin
    for
      Select
          i.codproduto
        , i.quantidade
        , e.quantidade as estoque
      from TBCLIENTE_REQUISICAO_ITEM i
        left join TBCLIENTE_ESTOQUE e on (e.cod_cliente = new.codcliente and e.cod_produto = i.codproduto)
      where i.ano    = new.ano
        and i.numero = new.numero
      Into
          produto
        , quantidade
        , estoque
    do
    begin

      Update TBCLIENTE_ESTOQUE e Set
        e.quantidade = coalesce(:estoque, 0) + coalesce(:quantidade, 0) -- Devolver estoque
      where e.cod_cliente = new.codcliente
        and e.cod_produto = :produto;

    end 
  end
end^

/*------ 29/10/2013 15:44:38 --------*/

SET TERM ; ^

/*------ 29/10/2013 19:12:26 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ADD VALOR_MEDIO DMN_MONEY_4;

/*------ 29/10/2013 19:12:26 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ADD VALOR_MEDIO DMN_MONEY_4;

/*------ 29/10/2013 19:12:27 --------*/

SET TERM ^ ;

ALTER TRIGGER TG_VENDAS_ESTOQUE_CLIENTE
AS
  declare variable produto varchar(10);
  declare variable quantidade integer;
  declare variable estoque integer;
  declare variable valor_medio numeric(15,4);
  declare variable valor_venda numeric(15,2);
begin

  /* Gerar Estoque para o Cliente na Finalizacao da Venda */

  if ( (coalesce(old.Status, 0) <> coalesce(new.Status, 0)) and (new.Status = 3)) then /* 3. Finalizada */
  begin
    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida
          , coalesce(c.quantidade, 0) -- Estoque
          , (coalesce(c.valor_medio, 0) * coalesce(c.quantidade, 0))
          , i.total_liquido
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
          , valor_medio
          , valor_venda
      do
      begin

        -- Recalcular valor medio ja existente
        if ( :estoque <= 0 ) then
          valor_medio = 0.0;

        -- Gerar novo valor medio
        valor_medio = (:valor_medio + :valor_venda) / (:quantidade + :estoque);

        if (not exists(
          Select
            ec.cod_cliente
          from TBCLIENTE_ESTOQUE ec
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto
        )) then
        begin

          -- Gerar Estoque
          Insert Into TBCLIENTE_ESTOQUE (
              cod_cliente
            , cod_produto
            , quantidade
            , valor_medio
            , usuario
            , ano_venda_ult
            , cod_venda_ult
          ) values (
              new.codcli
            , :produto
            , :quantidade
            , :valor_medio
            , new.usuario
            , new.ano
            , new.codcontrol
          );

        end
        else
        begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
              ec.quantidade  = coalesce(:quantidade, 0) + coalesce(:estoque, 0)
            , ec.valor_medio = :valor_medio
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

        end 

      end 

    end
  end

  else

  /* Atualizar Estoque do Cliente no Cancelamento da Venda */

  if ( (coalesce(old.Status, 0) in (3, 4)) and (new.Status = 5)) then /* 5. Cancelada */
  begin

    if ( new.gerar_estoque_cliente = 1 ) then
    begin

      for
        Select
            i.Codprod
          , i.Qtde                    -- Quantidade vendida cancelada
          , coalesce(c.quantidade, 0) -- Estoque
        from TVENDASITENS i
          left join TBCLIENTE_ESTOQUE c on (c.cod_cliente = new.codcli and c.cod_produto = i.codprod)
        where i.Ano        = new.Ano
          and i.Codcontrol = new.Codcontrol
        into
            produto
          , quantidade
          , estoque
      do
      begin

          -- Atualizar estoque cliente
          Update TBCLIENTE_ESTOQUE ec Set
            ec.quantidade = coalesce(:estoque, 0) - coalesce(:quantidade, 0)
          where ec.cod_cliente = new.codcli
            and ec.cod_produto = :produto;

      end

    end

  end

end^

/*------ 29/10/2013 19:12:27 --------*/

SET TERM ; ^

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN COD_CLIENTE POSITION 1;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN COD_PRODUTO POSITION 2;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN QUANTIDADE POSITION 3;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN VALOR_MEDIO POSITION 4;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN USUARIO POSITION 5;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN ANO_VENDA_ULT POSITION 6;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE ALTER COLUMN COD_VENDA_ULT POSITION 7;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ANO POSITION 1;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN NUMERO POSITION 2;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN ITEM POSITION 3;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODEMPRESA POSITION 4;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODCLIENTE POSITION 5;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN CODPRODUTO POSITION 6;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE POSITION 7;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN QUANTIDADE_FINAL POSITION 8;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN VALOR_MEDIO POSITION 9;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN UNIDADE POSITION 10;

/*------ 29/10/2013 19:12:27 --------*/

ALTER TABLE TBCLIENTE_REQUISICAO_ITEM ALTER COLUMN USUARIO POSITION 11;


/*------ SYSDBA 30/10/2013 10:58:53 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_INTEGER_N'
where (RDB$FIELD_NAME = 'QTDE') and
(RDB$RELATION_NAME = 'TBCOMPRASITENS')
;



/*------ 30/10/2013 16:24:02 --------*/

COMMENT ON COLUMN TBCLIENTE_REQUISICAO.RECEBEDOR_RG IS
'Documento do responsavel.

Ex.: RG 3320124 SSP/PA

(30/10/2013) RG do requerente/recebedor';

/*------ 10/11/2013 15:42:41 --------*/

CREATE DOMAIN DMN_VCHAR_20 AS VARCHAR(20);

/*------ 10/11/2013 15:42:41 --------*/

CREATE DOMAIN DMN_VCHAR_30 AS VARCHAR(30);

/*------ 10/11/2013 15:42:41 --------*/

ALTER TABLE TBUSERS ADD PERM_ALTERAR_VALOR_VENDA DMN_LOGICO DEFAULT 0;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOME POSITION 1;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN SENHA POSITION 2;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOMECOMPLETO POSITION 3;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN CODFUNCAO POSITION 4;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN LIMIDESC POSITION 5;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN ATIVO POSITION 6;

/*------ 10/11/2013 15:42:42 --------*/

ALTER TABLE TBUSERS ALTER COLUMN PERM_ALTERAR_VALOR_VENDA POSITION 7;

/*------ 11/11/2013 21:02:28 --------*/

ALTER TABLE TBUSERS ADD ALTERAR_SENHA DMN_LOGICO DEFAULT 0;

/*------ 11/11/2013 21:02:28 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOME POSITION 1;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN SENHA POSITION 2;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN NOMECOMPLETO POSITION 3;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN CODFUNCAO POSITION 4;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN LIMIDESC POSITION 5;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN ATIVO POSITION 6;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN ALTERAR_SENHA POSITION 7;

/*------ 11/11/2013 21:02:29 --------*/

ALTER TABLE TBUSERS ALTER COLUMN PERM_ALTERAR_VALOR_VENDA POSITION 8;

/*------ 12/11/2013 12:51:17 --------*/

CREATE TABLE TBCOMPETENCIA(CMP_NUM DMN_INTEGER_NN NOT NULL,
CMP_DESC DMN_VCHAR_50);

/*------ 12/11/2013 12:51:17 --------*/

ALTER TABLE TBVENDAS ADD COMPETENCIA DMN_INTEGER_N;

/*------ 12/11/2013 12:51:17 --------*/

SET TERM ^ ;

CREATE PROCEDURE SET_COMPETENCIA(NUMERO INTEGER,
DESCRICAO VARCHAR(50))
 AS
 BEGIN EXIT; END^

/*------ 12/11/2013 12:51:17 --------*/

SET TERM ; ^

ALTER TABLE TBCOMPETENCIA ADD CONSTRAINT PK_TBCOMPETENCIA PRIMARY KEY (CMP_NUM);

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ADD CONSTRAINT FK_TBVENDAS_COMPETENCIA FOREIGN KEY (COMPETENCIA) REFERENCES TBCOMPETENCIA (CMP_NUM);

/*------ 12/11/2013 12:51:18 --------*/

SET TERM ^ ;

ALTER PROCEDURE SET_COMPETENCIA(NUMERO INTEGER,
DESCRICAO VARCHAR(50))
 AS
begin
  if (not exists(
    Select
      c.cmp_num
    from TBCOMPETENCIA c
    where c.cmp_num = :numero
  )) then
  begin

    Insert Into TBCOMPETENCIA (
        cmp_num
      , cmp_desc
    ) values (
        :numero
      , :descricao
    );

  end
  else
  begin

    Update TBCOMPETENCIA c Set
      c.cmp_desc = :descricao
    where c.cmp_num = :numero
      and c.cmp_desc is null;

  end 
end^

/*------ 12/11/2013 12:51:18 --------*/

CREATE TRIGGER TG_VENDAS_COMPETENCIA FOR TBVENDAS
ACTIVE BEFORE INSERT OR UPDATE POSITION 5 
AS
  declare variable competencia Integer;
begin
  if ( coalesce(new.competencia, 0) = 0 ) then
  begin
    competencia = right('0000' || extract(year from new.dtvenda), 4) || right('00' || extract(month from new.dtvenda), 2);
    execute procedure SET_COMPETENCIA(:competencia, null);
    new.competencia = :competencia;
  end
end^

/*------ 12/11/2013 12:51:18 --------*/

SET TERM ; ^

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN ANO POSITION 1;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODCONTROL POSITION 2;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODEMP POSITION 3;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CODCLI POSITION 4;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DTVENDA POSITION 5;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN COMPETENCIA POSITION 6;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN STATUS POSITION 7;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALVENDA_BRUTA POSITION 8;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DESCONTO POSITION 9;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALVENDA POSITION 10;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN TOTALCUSTO POSITION 11;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DTFINALIZACAO_VENDA POSITION 12;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN OBS POSITION 13;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FORMAPAG POSITION 14;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FATDIAS POSITION 15;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN SERIE POSITION 16;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE POSITION 17;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN DATAEMISSAO POSITION 18;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN HORAEMISSAO POSITION 19;

/*------ 12/11/2013 12:51:18 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CFOP POSITION 20;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VERIFICADOR_NFE POSITION 21;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN XML_NFE POSITION 22;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VENDEDOR_COD POSITION 23;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN USUARIO POSITION 24;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN FORMAPAGTO_COD POSITION 25;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CONDICAOPAGTO_COD POSITION 26;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN VENDA_PRAZO POSITION 27;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_01 POSITION 28;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_02 POSITION 29;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_03 POSITION 30;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_04 POSITION 31;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_05 POSITION 32;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_06 POSITION 33;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_07 POSITION 34;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_08 POSITION 35;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_09 POSITION 36;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_10 POSITION 37;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_11 POSITION 38;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN PRAZO_12 POSITION 39;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_ANO POSITION 40;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_NUMERO POSITION 41;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN LOTE_NFE_RECIBO POSITION 42;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_ENVIADA POSITION 43;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_USUARIO POSITION 44;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_DATAHORA POSITION 45;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CANCEL_MOTIVO POSITION 46;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN XML_NFE_FILENAME POSITION 47;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_MODALIDADE_FRETE POSITION 48;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_TRANSPORTADORA POSITION 49;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_VEICULO POSITION 50;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_UF POSITION 51;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_PLACA_RNTC POSITION 52;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_BASE_ICMS POSITION 53;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_ICMS POSITION 54;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_BASE_ICMS_SUBST POSITION 55;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_ICMS_SUBST POSITION 56;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_PRODUTO POSITION 57;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_FRETE POSITION 58;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_SEGURO POSITION 59;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_DESCONTO POSITION 60;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_II POSITION 61;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_IPI POSITION 62;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_PIS POSITION 63;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_COFINS POSITION 64;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_OUTROS POSITION 65;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN NFE_VALOR_TOTAL_NOTA POSITION 66;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_PERCENTUAL POSITION 67;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_FRETE POSITION 68;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN CUSTO_OPER_OUTROS POSITION 69;

/*------ 12/11/2013 12:51:19 --------*/

ALTER TABLE TBVENDAS ALTER COLUMN GERAR_ESTOQUE_CLIENTE POSITION 70;

/*------ 12/11/2013 12:51:19 --------*/

GRANT ALL ON TBCOMPETENCIA TO PUBLIC;

/*------ 12/11/2013 12:51:19 --------*/

GRANT ALL ON TBCOMPETENCIA TO SYSDBA WITH GRANT OPTION;

/*------ 12/11/2013 14:01:55 --------*/

CREATE VIEW VW_STATUS_VENDA(
CODIGO,
DESCRICAO)
 AS 
Select 1 as Codigo , 'Em atendimento' as Descricao from RDB$DATABASE Union
Select 2 as Codigo , 'Aberta'       as Descricao from RDB$DATABASE Union
Select 3 as Codigo , 'Finalizada'   as Descricao from RDB$DATABASE Union
Select 4 as Codigo , 'NF-e Emitida' as Descricao from RDB$DATABASE Union
Select 5 as Codigo , 'Cancelada'    as Descricao from RDB$DATABASE;

/*------ 12/11/2013 14:01:55 --------*/

GRANT ALL ON VW_STATUS_VENDA TO PUBLIC;

/*------ 12/11/2013 14:01:55 --------*/

GRANT ALL ON VW_STATUS_VENDA TO SYSDBA WITH GRANT OPTION;


/*------ SYSDBA 17/12/2013 14:08:40 --------*/

ALTER TABLE TBCLIENTE_ESTOQUE DROP CONSTRAINT PK_TBCLIENTE_ESTOQUE;




/*------ SYSDBA 17/12/2013 14:08:52 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_INTEGER_NN'
where (RDB$FIELD_NAME = 'COD_CLIENTE') and
(RDB$RELATION_NAME = 'TBCLIENTE_ESTOQUE')
;




/*------ SYSDBA 17/12/2013 14:09:05 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_INTEGER_N'
where (RDB$FIELD_NAME = 'CODCLIENTE') and
(RDB$RELATION_NAME = 'TBCLIENTE_REQUISICAO')
;




/*------ SYSDBA 17/12/2013 14:09:16 --------*/

update RDB$RELATION_FIELDS set
RDB$FIELD_SOURCE = 'DMN_INTEGER_N'
where (RDB$FIELD_NAME = 'CODCLIENTE') and
(RDB$RELATION_NAME = 'TBCLIENTE_REQUISICAO_ITEM')
;

