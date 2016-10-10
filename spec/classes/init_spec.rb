require 'spec_helper'
describe 'imdate' do

  context 'with defaults for all parameters' do
    it { should contain_class('imdate') }
  end
end
