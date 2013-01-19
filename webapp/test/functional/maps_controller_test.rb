require 'test_helper'

class MapsControllerTest < ActionController::TestCase
  setup do
    @user = users(:robert)
    @user_two = users(:john)

    @map = maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:maps)
  end

  test "should get new as logged in" do
    sign_in @user

    get :new
    assert_response :success
  end

  test "should not get new as logged out" do
    get :new
    assert_redirected_to new_user_session_path
  end

  test "should create map as logged in" do
    sign_in @user

    assert_difference('Map.count') do
      post :create, map: { description: @map.description, name: @map.name }
    end

    assert_redirected_to map_path(assigns(:map))
  end

  test "should not create map as logged out" do
    post :create, map: { description: @map.description, name: @map.name }

    assert_redirected_to new_user_session_path
  end

  test "should show map" do
    get :show, id: @map
    assert_response :success
  end

  test "should get edit as logged in" do
    sign_in @user

    get :edit, id: @map
    assert_response :success
  end

  test "should not get edit as logged out" do
    get :edit, id: @map

    assert_redirected_to new_user_session_path
  end

  test "should update map as logged in as owner" do
    sign_in @map.user

    put :update, id: @map, map: { description: @map.description, name: @map.name }
    assert_redirected_to map_path(assigns(:map))
  end

  test "should not update map as logged in as non-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    put :update, id: @map, map: { description: @map.description, name: @map.name }
    assert_redirected_to new_user_session_path
  end

  test "should not update map as logged out" do
    put :update, id: @map, map: { description: @map.description, name: @map.name }
    assert_redirected_to new_user_session_path
  end

  test "should destroy map as logged in as owner" do
    sign_in @map.user

    assert_difference('Map.count', -1) do
      delete :destroy, id: @map
    end

    assert_redirected_to maps_path
  end

  test "should not destroy map as logged in as non-owner" do
    sign_in @user_two
    assert_not_equal @map.user, @user_two

    assert_no_difference('Map.count') do
      delete :destroy, id: @map
    end

    assert_redirected_to new_user_session_path
  end

  test "should not destroy map as logged out" do
    assert_no_difference('Map.count') do
      delete :destroy, id: @map
    end

    assert_redirected_to new_user_session_path
  end
end
