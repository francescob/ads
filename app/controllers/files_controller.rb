# Serves Active Storage files only to the owner of the beneficiary they belong to.
# The default Active Storage routes are disabled (config/application.rb): their
# signed URLs never expire and work without login, too weak for health and legal documents.
class FilesController < ApplicationController
  def show
    attachment = ActiveStorage::Attachment.includes(:blob).find(params[:id])
    raise ActiveRecord::RecordNotFound unless owner_of?(attachment.record)

    send_data attachment.download,
              filename: attachment.filename.to_s,
              type: attachment.content_type,
              disposition: params[:disposition] == "inline" ? :inline : :attachment
  end

  private

  def owner_of?(record)
    beneficiary =
      case record
      when Beneficiary then record
      when ExpenseEntry, IncomeEntry then record.report&.beneficiary
      else record.try(:beneficiary)
      end
    beneficiary.present? && beneficiary.user_id == current_user.id
  end
end
