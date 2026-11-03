require "rails_helper"

RSpec.describe SignatureVerifier do
  let(:original) { sample_pdf }

  def verify(signed, original: self.original)
    described_class.new(signed, original: original).call
  end

  context "with a signed PDF (PAdES)" do
    it "accepts a qualified signature on the generated PDF" do
      result = verify(pades(original))
      expect(result.status).to eq(:valid_untrusted)
      expect(result.format).to eq("pades")
      expect(result.signer_name).to eq("Mario Rossi")
      expect(result.signer_tax_code).to eq("RSSMRA80A01H501Z")
      expect(result.issuer).to eq("Prova Qualified CA")
      expect(result.qualified).to be(true)
      expect(result.matches_original).to be(true)
      expect(result.details["errors"]).to be_empty
      expect(result.details["checks"]).to include("integrity" => true, "covers_whole_file" => true, "trust_chain" => "not_checked")
    end

    it "detects changes after signing" do
      expect(verify(pades(original) + "\n% added later\n").details["errors"]).to include("modified_after_signature")
    end

    it "detects a tampered signed region" do
      signed = pades(original).sub("/Count 0", "/Count 9")
      result = verify(signed, original: nil)
      expect(result.status).to eq(:invalid)
      expect(result.details["errors"]).to include("integrity")
    end

    it "flags a signature on a different document" do
      result = verify(pades(original.sub("/Count 0", "/Count 1")))
      expect(result.status).to eq(:mismatch)
      expect(result.matches_original).to be(false)
    end

    it "recognises a later document timestamp as a timestamp, not as a change" do
      signed = pades(pades(original), sub_filter: "ETSI.RFC3161")
      result = verify(signed)
      expect(result.status).to eq(:valid_untrusted)
      expect(result.timestamped).to be(true)
    end

    it "rejects a PDF without signatures" do
      result = verify(original)
      expect(result.status).to eq(:invalid)
      expect(result.details["errors"]).to eq([ "unreadable" ])
    end
  end

  context "with a .p7m (CAdES)" do
    it "accepts an attached signature, also Base64-encoded" do
      [ cades(original), cades(original, base64: true) ].each do |p7m|
        result = verify(p7m)
        expect(result.status).to eq(:valid_untrusted)
        expect(result.format).to eq("cades")
        expect(result.matches_original).to be(true)
        expect(result.signed_at).to be_within(1.minute).of(Time.current)
      end
    end

    it "verifies a detached signature against the generated PDF" do
      expect(verify(cades(original, detached: true)).status).to eq(:valid_untrusted)
      expect(verify(cades(original, detached: true), original: original + "x").status).to eq(:invalid)
    end

    it "flags content different from the generated PDF" do
      expect(verify(cades("another document")).status).to eq(:mismatch)
    end

    it "warns when the original was never generated" do
      result = verify(cades(original), original: nil)
      expect(result.status).to eq(:valid_untrusted)
      expect(result.matches_original).to be_nil
      expect(result.details["warnings"]).to include("original_missing")
    end
  end

  context "certificate checks" do
    it "rejects a certificate expired at signing time" do
      signer = signer_certificate(not_before: 3.years.ago, not_after: 1.year.ago)
      result = verify(cades(original, signer: signer))
      expect(result.status).to eq(:invalid)
      expect(result.details["errors"]).to include("certificate_not_valid_at_signing")
    end

    it "warns about non-qualified certificates and missing non-repudiation" do
      signer = signer_certificate(qualified: false, non_repudiation: false)
      result = verify(cades(original, signer: signer))
      expect(result.status).to eq(:valid_untrusted)
      expect(result.qualified).to be(false)
      expect(result.details["warnings"]).to include("not_qualified", "no_non_repudiation")
    end
  end

  it "rejects files that are not signatures" do
    expect(verify("just text").details["errors"]).to eq([ "unreadable" ])
  end
end
