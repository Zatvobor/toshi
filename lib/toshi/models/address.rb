module Toshi
  module Models
    class Address < Sequel::Model

      many_to_many :outputs

      def unspent_outputs
        Output.join(:unspent_outputs, :output_id => :id).where(address_id: id)
      end

      def spent_outputs
        outputs_dataset.where(spent: true, branch: Block::MAIN_BRANCH)
      end

      def balance
        total_received - total_sent
      end

      def utxo_balance
        # if this isn't the same as the cached balance it's a problem.
        Toshi.db[:unspent_outputs].where(address_id: id).sum(:amount).to_i || 0
      end

      def balance_at(block_height)
        # sum the ledger entries for this address on the main branch up to this height
        sum = Toshi.db[:address_ledger_entries]
          .where(address_id: id)
          .join(:transactions, :id => :transaction_id)
          .where(pool: Transaction::TIP_POOL)
          .where("height <= #{block_height}")
          .sum(:amount).to_i
        sum || 0
      end

      def transaction_ids(offset=0, limit=nil, order=Sequel.desc(:id))
        tids = Toshi.db[:address_ledger_entries]
          .where(address_id: id)
          .select(:transaction_id).group_by(:transaction_id)
          .order(Sequel.desc(:transaction_id))
          .offset(offset)
          .limit(limit)
          .map(:transaction_id)
        tids.any? ? tids : []
      end

      def transactions(offset=0, limit=nil, order=Sequel.desc(:id))
        tids = transaction_ids(offset, limit, order)
        Transaction.where(id: tids).order(order)
      end

      def btc
        ("%.8f" % (balance / 100000000.0)).to_f
      end

      HASH160_TYPE = 0
      P2SH_TYPE    = 1

      def type
        case address_type
        when HASH160_TYPE; :hash160
        when P2SH_TYPE;    :p2sh
        end
      end

      def to_hash(options={})
        self.class.to_hash_collection([self], options).first
      end

      def self.to_hash_collection(addresses, options={})
        Toshi::Utils.sanitize_options(options)

        collection = []

        addresses.each{|address|
          hash = {}
          hash[:hash] = address.address
          hash[:hash160] = address.hash160
          hash[:balance] = address.balance
          hash[:received] = address.total_received
          hash[:sent] = address.total_sent

          unconfirmed_address = Toshi::Models::UnconfirmedAddress.where(address: address.address).first
          hash[:unconfirmed_received] = unconfirmed_address ? unconfirmed_address.total_received : 0
          hash[:unconfirmed_sent] = unconfirmed_address ? unconfirmed_address.total_sent(address) : 0
          hash[:unconfirmed_balance] = unconfirmed_address ? unconfirmed_address.balance(address) : 0

          if options[:show_txs]
            if unconfirmed_address
              hash[:unconfirmed_transactions] = UnconfirmedTransaction.to_hash_collection(unconfirmed_address.transactions)
              hash[:no_unconfirmed_transactions] = unconfirmed_address.transactions.count
            end

            transactions = address.transactions(options[:offset], options[:limit])
            transactions = Transaction.to_hash_collection(transactions)

            if (!transactions.empty? && order_by = options[:order_by].expression)
              transactions.sort! {|x,y| (y[order_by]||0) <=> (x[order_by]||0) } if transactions.first.has_key?(order_by)
            end

            hash[:transactions]     = transactions
            hash[:no_transactions]  = address.transaction_ids.count
          end

          collection << hash
        }

        return collection
      end

      def to_json(options={})
        to_hash(options).to_json
      end
    end
  end
end
