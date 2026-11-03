# Upload / removal of the digitally signed version of a report (signed outside the app).
class SignaturesController < ApplicationController
  before_action :set_report

  def create
    file = params.dig(:signature, :signed_file)
    return redirect_to @report, alert: t("signatures.no_file") if file.blank?

    # Not build_signature: on a has_one it would destroy the current signature before validating the new one
    signature = Signature.new(signable: @report, signed_file: file, uploaded_by: current_user)
    if signature.valid?
      Signature.transaction do
        @report.signature&.destroy! # one signed version per report: replace it
        signature.save!
      end
      signature.verify!
      redirect_to @report, **flash_for(signature)
    else
      redirect_to @report, alert: signature.errors.full_messages.to_sentence
    end
  end

  def destroy
    @report.signature&.destroy
    redirect_to @report, notice: t("signatures.removed"), status: :see_other
  end

  private

  def set_report
    @report = Report.owned_by(current_user).find(params[:report_id])
  end

  def flash_for(signature)
    signature.ok? ? { notice: t("signatures.uploaded_ok") } : { alert: t("signatures.uploaded_with_problems") }
  end
end
