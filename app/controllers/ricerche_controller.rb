# Ricerca globale dalla barra di navigazione.
class RicercheController < ApplicationController
  def show
    @q = params[:q].to_s.strip
    return if @q.length < 2

    like = "%#{Beneficiario.sanitize_sql_like(@q)}%"
    @beneficiari = Beneficiario.cerca(@q).ordinati.limit(20)
    @procedimenti = Procedimento.includes(:beneficiario)
                                .where("numero_rg LIKE :q OR tribunale LIKE :q OR giudice_tutelare LIKE :q", q: like).limit(20)
    @contatti = Contatto.includes(:beneficiario).where("nome LIKE :q OR ruolo LIKE :q OR email LIKE :q", q: like).limit(20)
    @documenti = Documento.includes(procedimento: :beneficiario).where("titolo LIKE :q OR note LIKE :q", q: like).limit(20)
    @istanze = Istanza.includes(procedimento: :beneficiario).where("oggetto LIKE :q OR esito LIKE :q", q: like).limit(20)
  end
end
