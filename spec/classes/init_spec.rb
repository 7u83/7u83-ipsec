require 'spec_helper'
describe 'ipsec' do
  context 'with default values for all parameters' do
    it { should contain_class('ipsec') }
  end
end
