require_relative '../../../spec_helper'
require_relative '../../../library/digest/sha1/shared/constants'
require_relative '../../../library/digest/sha256/shared/constants'
require_relative '../../../library/digest/sha384/shared/constants'
require_relative '../../../library/digest/sha512/shared/constants'
require 'openssl'

describe "OpenSSL::Digest#digest_length" do
  describe "digest_length of OpenSSL::Digest.new(name)" do
    it "returns a SHA1 block length" do
      OpenSSL::Digest.new('sha1').digest_length.should == SHA1Constants::DigestLength
    end

    it "returns a SHA256 block length" do
      OpenSSL::Digest.new('sha256').digest_length.should == SHA256Constants::DigestLength
    end

    it "returns a SHA384 digest_length" do
      OpenSSL::Digest.new('sha384').digest_length.should == SHA384Constants::DigestLength
    end

    it "returns a SHA512 digest_length" do
      OpenSSL::Digest.new('sha512').digest_length.should == SHA512Constants::DigestLength
    end
  end

  describe "digest_length of subclasses" do
    it "returns a SHA1 block length" do
      OpenSSL::Digest::SHA1.new.digest_length.should == SHA1Constants::DigestLength
    end

    it "returns a SHA256 block length" do
      OpenSSL::Digest::SHA256.new.digest_length.should == SHA256Constants::DigestLength
    end

    it "returns a SHA384 digest_length" do
      OpenSSL::Digest::SHA384.new.digest_length.should == SHA384Constants::DigestLength
    end

    it "returns a SHA512 digest_length" do
      OpenSSL::Digest::SHA512.new.digest_length.should == SHA512Constants::DigestLength
    end
  end
end
