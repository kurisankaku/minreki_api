module ErrorExamples
  shared_examples "bad request error" do |code, field|
    it "raise bad request erro code is #{code}, field is #{field}" do
      begin
        subject
        fail
      rescue BadRequestError => e
        expect(e.code).to eq (code)
        expect(e.field).to eq (field)
      end
    end
  end
end
