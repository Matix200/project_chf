class WalletsController < ApplicationController
  before_action :set_wallet, only: [:show, :edit, :update, :destroy]

  # GET /wallets
  # GET /wallets.json
  def index
    @wallets = Wallet.all
  end

  # GET /wallets/1
  # GET /wallets/1.json
  def show
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit
    @wallet = current_user.wallet

    respond_to do |format|
      if @wallet.coin_type || @wallet.network_address
        format.js { render partial: 'blockchain/choose_payment' }
      end
    end

  end

  # POST /wallets
  def claim_code
    @wallet = Wallet.find_by_code(params[:wallet][:code])

    respond_to do |format|
      if @wallet
        if @wallet.user
          format.html { redirect_to blockchain_path, notice: 'Rybka jest juz w uzyciu' }
        else
          @wallet.user = current_user
          @wallet.save!
          format.html { redirect_to blockchain_dashboard_path, notice: 'Rybka odebrana' }
        end
      else
        # fucked up!!
        format.html { redirect_to blockchain_path, notice: 'Rybka nie istnieje' }
      end
    end
  end

  # POST /wallets.json
  def create
    @wallet = Wallet.new(wallet_params)

    respond_to do |format|
      if @wallet.save
        format.html { redirect_to @wallet, notice: 'Wallet was successfully created.' }
        format.json { render :show, status: :created, location: @wallet }
      else
        format.html { render :new }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallets/1
  # PATCH/PUT /wallets/1.json
  def update
    respond_to do |format|
      if @wallet.update(wallet_params)
        format.html { redirect_to @wallet, notice: 'Wallet was successfully updated.' }
        format.json { render :show, status: :ok, location: @wallet }
      else
        format.html { render :edit }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallets/1
  # DELETE /wallets/1.json
  def destroy
    @wallet.destroy
    respond_to do |format|
      format.html { redirect_to wallets_url, notice: 'Wallet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wallet_params
      params.require(:wallet).permit(:code, :coin_type, :limit, :network_address)
    end
end
