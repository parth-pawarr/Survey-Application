# Script for seeding the database with initial data

alias RuralSurvey.Surveys.Village
alias RuralSurvey.Mongo
alias Mongo

# Seed villages
IO.puts("Seeding villages...")

# Clear existing villages
Mongo.delete_many(:mongo, "villages", %{})

# Insert sample villages
villages = [
  %{
    name: "Rampur",
    district: "Bareilly",
    state: "Uttar Pradesh",
    createdAt: DateTime.utc_now()
  },
  %{
    name: "Shivpur",
    district: "Varanasi",
    state: "Uttar Pradesh",
    createdAt: DateTime.utc_now()
  },
  %{
    name: "Gopalpur",
    district: "Lucknow",
    state: "Uttar Pradesh",
    createdAt: DateTime.utc_now()
  },
  %{
    name: "Madhavpur",
    district: "Kanpur Nagar",
    state: "Uttar Pradesh",
    createdAt: DateTime.utc_now()
  },
  %{
    name: "Krishnapur",
    district: "Allahabad",
    state: "Uttar Pradesh",
    createdAt: DateTime.utc_now()
  }
]

Enum.each(villages, fn village ->
  case Mongo.insert_one(:mongo, "villages", village) do
    {:ok, _} -> IO.puts("  ✓ Created village: #{village.name}")
    {:error, error} -> IO.puts("  ✗ Error creating village: #{inspect(error)}")
  end
end)

# Seed users
IO.puts("\nSeeding users...")

# Clear existing users
Mongo.delete_many(:mongo, "users", %{})

# Hash passwords
import Pbkdf2

users = [
  %{
    username: "admin",
    email: "admin@survey.com",
    full_name: "Administrator",
    password_hash: Pbkdf2.hash_pwd_salt("admin123"),
    role: "admin",
    is_active: true,
    createdAt: DateTime.utc_now(),
    updatedAt: DateTime.utc_now()
  },
  %{
    username: "surveyor1",
    email: "surveyor1@survey.com",
    full_name: "John Surveyor",
    password_hash: Pbkdf2.hash_pwd_salt("survey123"),
    role: "surveyor",
    is_active: true,
    createdAt: DateTime.utc_now(),
    updatedAt: DateTime.utc_now()
  },
  %{
    username: "surveyor2",
    email: "surveyor2@survey.com",
    full_name: "Jane Surveyor",
    password_hash: Pbkdf2.hash_pwd_salt("survey123"),
    role: "surveyor",
    is_active: true,
    createdAt: DateTime.utc_now(),
    updatedAt: DateTime.utc_now()
  }
]

Enum.each(users, fn user ->
  case Mongo.insert_one(:mongo, "users", user) do
    {:ok, _} -> IO.puts("  ✓ Created user: #{user.username}")
    {:error, error} -> IO.puts("  ✗ Error creating user: #{inspect(error)}")
  end
end)

IO.puts("\nDatabase seeding completed!")
IO.puts("\nLogin credentials:")
IO.puts("Admin: username=admin, password=admin123")
IO.puts("Surveyor 1: username=surveyor1, password=survey123")
IO.puts("Surveyor 2: username=surveyor2, password=survey123")
