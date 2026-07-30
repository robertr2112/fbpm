# Service object to encapsulate Pool diagnostics logic
module Diagnostics
  class PoolDiagnostics
    def initialize(params = {})
      @params = params
    end

    # Prepare data for the diagnostics view
    # Returns a hash with :pool and :season
    def show(pool)
      season = Season.find_by_id(pool.season.id)
      { pool: pool, season: season }
    end

    # Handle change actions currently implemented in PoolsController#pool_diag_chg
    # Accepts the controller params (or a Hash with similar keys) and returns the affected Pool
    def handle_change(params)
      if params[:surv]
        entry = Entry.find_by_id(params[:entry_id])
        pool = Pool.find_by_id(entry.pool_id)
        # toggle survivor status
        entry.update!(survivorStatusIn: !entry.survivorStatusIn)

      elsif params[:pool_status]
        pool = Pool.find_by_id(params[:pool_id])
        # toggle pool_done flag
        pool.update!(pool_done: !pool.pool_done)

      else
        # fallback: try to find a pool from common param keys
        pool = Pool.find_by_id(params[:pool_id] || params[:id])
      end

      pool
    end
  end
end
