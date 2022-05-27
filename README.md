# HVS

The Home Visit Service ("HVS") manages users who fill one or both of two roles:
**member** or **pal**. "Members" register requests for a visit and "Pals" can fulfill those requests.

## Running the Server

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

All routes can be seen by running `mix phx.routes`.

## Running Tests

Use `mix test` to run the automated tests.

## API

All API calls are made to the `/api` domain. These calls require a key in the `x-api-key` request header (default value:
"_default-hvs-api-key_").

The most important routes are (together with required body fields and helper script call):

### **CREATE USER**

ROUTE

    POST /api/users

BODY

```json
{
  "first_name": "",
  "last_name": "",
  "email": ""
}
```

SCRIPT

```bash
	./run.sh create_user "first name" "last name" "email"
```

---

### **FETCH USER LIST**

ROUTE

    GET /api/users

SCRIPT

```bash
	./run.sh user_list
```

---

### **REQUEST VISIT**

ROUTE

    POST /api/users/:user_id/request

BODY

```json
{
  "member": 0,
  "date": "",
  "minutes": 0,
  "tasks": ""
}
```

SCRIPT

```bash
	./run.sh request_visit member_id "iso 8601 utc datetime" minutes "tasks"
```

---

### **FETCH VISIT LIST**

ROUTE

    GET /api/visits

SCRIPT

```bash
	./run.sh visits_list
```

---

### **FULFILL VISIT**

ROUTE

    POST /api/visits/:visit_id/fulfill

BODY

```json
{
  "pal_id": 0
}
```

SCRIPT

```bash
	./run.sh fulfill_visit visit_id pal_id
```
