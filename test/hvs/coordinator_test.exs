defmodule HVS.CoordinatorTest do
  use HVS.DataCase

  import HVS.UsersFixtures
  import HVS.VisitsFixtures

  alias HVS.Coordinator, as: TestMe
  alias HVS.{Users, Visits}

  @moduletag :capture_log

  describe "create_visit/1" do
    test "returns :ok if given valid params" do
      for _n <- 1..50 do
        %{id: id, mins_balance: balance} = user_fixture()
        params = valid_create_params(id, balance)

        assert {:ok, _id} = TestMe.create_visit(params)
      end
    end

    test "returns :error tuple if missing param" do
      %{id: id, mins_balance: balance} = user_fixture()

      params = valid_create_params(id, balance)
      key = params |> Map.keys() |> Enum.random()
      params = Map.delete(params, key)

      assert {:error, _msg} = TestMe.create_visit(params)
    end

    test "returns :error tuple if non-existent user" do
      params = valid_create_params(1, 100)
      assert {:error, _msg} = TestMe.create_visit(params)
    end

    test "returns :error tuple if insufficient balance" do
      for _n <- 1..50 do
        balance = rand_integer()
        min = balance + rand_integer()
        minutes = Enum.random(min..20000)
        %{id: id} = user_fixture(%{mins_balance: balance})
        params = valid_create_params(id, balance, %{"minutes" => minutes})

        assert {:error, _msg} = TestMe.create_visit(params)

        # Zero balance case
        %{id: id} = user_fixture(%{mins_balance: 0})
        params = valid_create_params(id, balance, %{"minutes" => minutes})
        assert {:error, _msg} = TestMe.create_visit(params)
      end
    end
  end

  describe "fulfill_visit/2" do
    test "returns :ok if given valid params for existing entities" do
      for _n <- 1..50 do
        balance = rand_integer()
        %{id: user_id} = user_fixture(mins_balance: balance)

        {:ok, %{id: visit_id, minutes: mins}} =
          user_id |> valid_create_params(balance) |> Visits.create_visit()

        %{id: pal_id, mins_balance: pal_balance} = user_fixture(mins_balance: rand_integer())

        member_result = max(0, balance - mins)
        pal_result = floor(0.85 * mins + pal_balance)
        assert :ok = TestMe.fulfill_visit(%{"pal_id" => pal_id, "visit_id" => visit_id})
        assert %{mins_balance: ^member_result} = Users.get_user!(user_id)
        assert %{mins_balance: ^pal_result} = Users.get_user!(pal_id)
      end
    end

    test "returns :error tuple if non-existent visit" do
      %{id: pal_id} = user_fixture()
      assert {:error, _} = TestMe.fulfill_visit(%{"pal_id" => pal_id, "visit_id" => 999})
    end

    test "returns :error tuple if non-existent pal" do
      %{id: member_id} = user_fixture()
      %{id: visit_id} = visit_fixture(%{member: member_id})
      assert {:error, _} = TestMe.fulfill_visit(%{"pal_id" => 999, "visit_id" => visit_id})
    end

    test "returns :error tuple if missing params" do
      params = %{"pal_id" => 1, "visit_id" => 1}
      assert {:error, _} = TestMe.fulfill_visit(Map.delete(params, "pal_id"))
      assert {:error, _} = TestMe.fulfill_visit(Map.delete(params, "visit_id"))
      assert {:error, _} = TestMe.fulfill_visit(%{})
    end
  end

  defp rand_integer(n \\ 10000), do: :rand.uniform(n)

  defp valid_create_params(id, balance, attr \\ %{}) do
    Map.merge(
      %{
        "member" => id,
        "date" => DateTime.utc_now(),
        "minutes" => Enum.random(1..balance),
        "tasks" => "things to do"
      },
      attr
    )
  end
end
