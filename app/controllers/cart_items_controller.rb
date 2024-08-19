class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[edit update destroy]
  before_action :set_cart, only: %i[create]

  def create
    product_id = params[:cart_item][:product_id]
    quantity = params[:cart_item][:quantity].to_i

    if current_user
      @cart = current_user.cart
      existing_cart_item = @cart.cart_items.find_by(product_id:)

      if existing_cart_item
        existing_cart_item.update(quantity: existing_cart_item.quantity + quantity)
      else
        @cart.cart_items.create(cart_item_params)
      end

      @cart.update(item_count: @cart.cart_items.sum(:quantity))

      redirect_to user_cart_path(current_user), notice: 'Item was successfully added to the cart.'
    else
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
      session[:cart_id] = @cart.id

      existing_cart_item = @cart.cart_items.find_by(product_id:)

      if existing_cart_item
        existing_cart_item.update(quantity: existing_cart_item.quantity + quantity)
      else
        @cart.cart_items.create(cart_item_params)
      end

      @cart.update(item_count: @cart.cart_items.sum(:quantity))

      redirect_to root_path, notice: 'Item was successfully added to the cart.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: 'Cart or product not found.'
  end

  def edit
  end

  def update
    if @cart_item.update(cart_item_params)
      redirect_to user_cart_path(@cart_item.cart.user), notice: 'Cart item was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Find the cart item
    binding.pry
    @cart_item = CartItem.find(params[:id])

    # Determine if the user is logged in or not
    if current_user
      # Handle removal for logged-in users
      @cart = current_user.cart
      @cart_item.destroy
      redirect_to user_cart_path(current_user), notice: 'Cart item was successfully removed.'
    else
      # Handle removal for non-logged-in users
      @cart = Cart.find(session[:cart_id])
      @cart_item.destroy
      redirect_to cart_path(@cart), notice: 'Cart item was successfully removed.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: 'Cart item not found.'
  end

  private

  def set_cart
    @cart = if current_user
              current_user.cart
            else
              Cart.find(session[:cart_id])
            end
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end

  def set_cart_item
    binding.pry
    @cart_item = CartItem.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity)
  end
end
