# encoding: utf-8
require 'spec_helper'

describe ConciliateAccount do
  it "only allow account ledgers" do
    expect { ConciliateAccount.new(Object.new) }.to raise_error
  end

  describe 'Conciliation' do
    before(:each) do
      UserSession.user = build :user, id: 1
    end

    it "does not conciliate null AccountLedger" do
      ledger = build :account_ledger, active: false
      con = ConciliateAccount.new(ledger)

      con.conciliate.should be_false
    end

    context "conciliate!" do
      let(:ac1) { build :cash, id: 1 }
      let(:ac2) { Income.new_income {|i| i.id = 2} }
      let(:ledger) {
        led = AccountLedger.new(amount: 100, currency: 'BOB')
        led.stub(account: ac1, account_to: ac2)
        led
      }

      before(:each) do
        AccountLedger.any_instance.stub(save: true)
        Account.any_instance.stub(save: true)
      end

      it "conciliate!" do
        con = ConciliateAccount.new(ledger)

        # Transaction
        ActiveRecord::Base.should_receive(:transaction)

        con.conciliate!
      end

      it "conciliate no transaction" do
        con = ConciliateAccount.new(ledger)

        # Transaction
        ActiveRecord::Base.should_not_receive(:transaction)

        con.conciliate
      end
    end

    context 'Income' do
      before(:each) do
        OrganisationSession.organisation = build :organisation, currency: 'BOB'
      end

      it "update only the account_to for Income" do
        income = build :income, id: 10, amount: 300, currency: 'BOB'
        cash = build :cash, id: 2, amount: 10, currency: 'BOB'

        al = AccountLedger.new(operation: 'payin', id: 10, amount: 100, conciliation: false)
        # stubs
        cash.should_receive(:save).and_return(true)
        al.should_receive(:save).and_return(true)

        al.account = income
        al.account_to = cash

        al.should_not be_conciliation

        ConciliateAccount.new(al).conciliate.should be_true

        al.should be_conciliation
        al.account_to_amount.should == 10 + 100

        al.approver_id.should eq(1)
        al.approver_datetime.should be_is_a(Time)
      end

      it "updates both accounts for  Bank and Cash" do
        ac_usd = build :cash, amount: 2000, currency: 'USD'
        ac_bob = build :bank, amount: 100, currency: 'BOB'

        al = AccountLedger.new(currency: ac_usd.currency, amount: 200, exchange_rate: 7.0, inverse: true)
        al.account = ac_usd
        al.account_to = ac_bob
        # stubs
        ac_usd.should_receive(:save).and_return(true)
        ac_bob.should_receive(:save).and_return(true)
        al.should_receive(:save).and_return(true)

        ConciliateAccount.new(al).conciliate.should be_true

        al.account_amount.round(2).should == 2000 - (200 * 1/7.0).round(2)
        al.account_to_amount.should == 300.0

        al.approver_id.should eq(1)
      end

      it "Only updates only the ledger when service payment" do
        income =  build :income, id: 1, currency: 'BOB', balance: 100
        expense = build :expense,  id: 2, balance: 50, currency: 'BOB'

        al = AccountLedger.new(operation: 'payin', id: 10, amount: 100, conciliation: false)
        # stubs
        al.should_receive(:save).and_return(true)

        al.account = income
        al.account_to = expense
        al.should_not be_conciliation
        al.approver_id.should be_nil
        al.approver_datetime.should be_nil

        ConciliateAccount.new(al).conciliate.should be_true

        al.should be_conciliation
        # Account don't change
        al.account_to_amount.should == 50

        al.approver_id.should eq(1)
        al.approver_datetime.should be_is_a(Time)
      end
    end
  end
end
