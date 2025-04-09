# frozen_string_literal: true

module Sai
  module Enum
    module Observer
      extend Enum

      value(:cie1931_2_degree) { Sai::Observer.load('observer/cie_1931_2_degree.yml', symbolize_names: true) }
      alias_value :cie1931, :cie1931_2_degree

      value(:cie1964_10_degree) { Sai::Observer.load('observer/cie_1964_10_degree.yml', symbolize_names: true) }
      alias_value :cie1964, :cie1964_10_degree

      value(:cie2006_2_degree) { Sai::Observer.load('observer/cie_2006_2_degree.yml', symbolize_names: true) }

      value(:cie2006_10_degree) { Sai::Observer.load('observer/cie_2006_10_degree.yml', symbolize_names: true) }

      value(:judd_2_degree) { Sai::Observer.load('observer/cie_1931_judd_2_degree.yml', symbolize_names: true) }
      alias_value :judd, :judd_2_degree

      value(:judd_voss_2_degree) do
        Sai::Observer.load('observer/cie_1931_judd_voss_2_degree.yml', symbolize_names: true)
      end
      alias_value :judd_voss, :judd_voss_2_degree

      value(:stiles_burch_2_degree) { Sai::Observer.load('observer/stiles_burch_2_degree.yml', symbolize_names: true) }

      value(:stiles_burch_10_degree) do
        Sai::Observer.load('observer/stiles_burch_10_degree.yml', symbolize_names: true)
      end

      value(:stockman_sharpe_2_degree) do
        Sai::Observer.load('observer/stockman_sharpe_2_degree.yml', symbolize_names: true)
      end

      value(:stockman_sharpe_10_degree) do
        Sai::Observer.load('observer/stockman_sharpe_10_degree.yml', symbolize_names: true)
      end
    end
  end
end
