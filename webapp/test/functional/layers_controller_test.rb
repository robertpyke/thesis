require 'test_helper'

class LayersControllerTest < ActionController::TestCase

  def get_csv_file
    fixture_file_upload "sample_layer_data.csv", "text/csv"
  end

  def get_asc_file
    fixture_file_upload "sample_ascii_grid.asc", "text/asc"
  end

  setup do
    @user = users(:robert)
    @user_two = users(:john)
    @map = maps(:one)

    @layer = layers(:one)
    @layer.csv_file = get_csv_file
  end

  test "should get index" do
    get :index, map_id: @map
    assert_response :success
    assert_not_nil assigns(:layers)
  end

  test "should get new as logged in as map owner" do
    sign_in @map.user

    get :new, map_id: @map
    assert_response :success
  end

  test "should not get new as logged is as non-map-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    get :new, map_id: @map
    assert_redirected_to new_user_session_path
  end

  test "should not get new as logged out" do
    get :new, map_id: @map
    assert_redirected_to new_user_session_path
  end

  test "should create layer from csv as logged in as map owner" do
    sign_in @map.user

    assert_difference('Layer.count') do
      post :create, map_id: @map, layer: { name: "new_name", csv_file: get_csv_file }
    end

    assert_redirected_to map_layer_path(@map, assigns(:layer))
  end

  test "should create layer from asc as logged in as map owner" do
    sign_in @map.user

    assert_difference('Layer.count') do
      post :create, map_id: @map, layer: { name: "new_name", renderable_file: get_asc_file }
    end

    assert_redirected_to map_layer_path(@map, assigns(:layer))
  end

  test "should not create layer as logged in as non-map-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    assert_no_difference('Layer.count') do
      post :create, map_id: @map, layer: { name: "new_name", csv_file: get_csv_file }
    end

    assert_redirected_to new_user_session_path
  end

  test "should not create layer as not logged in" do
    assert_no_difference('Layer.count') do
      post :create, map_id: @map, layer: { name: "new_name", csv_file: get_csv_file }
    end

    assert_redirected_to new_user_session_path
  end

  test "should show layer" do
    get :show, map_id: @map, id: @layer.to_param
    assert_response :success
  end

  test "should get edit as logged in as map owner" do
    sign_in @map.user

    get :edit, map_id: @map, id: @layer.to_param
    assert_response :success
  end

  test "should not get edit as logged in as non-map-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    get :edit, map_id: @map, id: @layer.to_param
    assert_redirected_to new_user_session_path
  end

  test "should not get edit as not logged in" do
    get :edit, map_id: @map, id: @layer.to_param
    assert_redirected_to new_user_session_path
  end

  test "should update layer as logged in as map owner" do
    sign_in @map.user

    put :update, map_id: @map, id: @layer.to_param, layer: { name: "new_name", csv_file: get_csv_file }
    assert_redirected_to map_layer_path(@map, assigns(:layer))
  end

  test "should not update layer as logged in as non-map-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    put :update, map_id: @map, id: @layer.to_param, layer: { name: "new_name", csv_file: get_csv_file }
    assert_redirected_to new_user_session_path
  end

  test "should not update layer as not logged in" do
    put :update, map_id: @map, id: @layer.to_param, layer: { name: "new_name", csv_file: get_csv_file }
    assert_redirected_to new_user_session_path
  end

  test "should destroy layer as logged in as map owner" do
    sign_in @map.user

    assert_difference('Layer.count', -1) do
      delete :destroy, map_id: @map, id: @layer.to_param
    end

    assert_redirected_to map_layers_path(@map)
  end

  test "should not destroy layer as logged in as non-map-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    assert_no_difference('Layer.count') do
      delete :destroy, map_id: @map, id: @layer.to_param
    end

    assert_redirected_to new_user_session_path
  end

  test "should not destroy layer as not logged in" do
    assert_no_difference('Layer.count') do
      delete :destroy, map_id: @map, id: @layer.to_param
    end

    assert_redirected_to new_user_session_path
  end
end
