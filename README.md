 **Milkshake Ordering System**

A modern full-stack application for ordering custom milkshakes online with real-time pricing, configurable discount tiers, a payment gateway, auditing, reports, and full restaurant pickup functionality.

 **Project Overview**

The Milkshake Ordering System is a complete digital solution designed to reduce long queues in-store by letting patrons order their milkshakes online, select a restaurant, choose a collection time, make payment, and receive receipts instantly.
The system includes a web backend, Flutter mobile/desktop frontend, SQL Server database, and a configurable management portal, fully aligned with the client's requirements.


  **Objectives**

Provide a modern customer-friendly ordering experience

Reduce in-store waiting time via pre-ordered pickups

Allow management to configure pricing, VAT, discounts, and lookups

Ensure auditable, secure, scalable, and maintainable architecture

Generate real-time reports for patrons and managers

Support mobile, web, and backend integration




**Key Features**



 **User Features**

Create an account / Login

Select restaurant + pickup time

Order 1–10 custom drinks

Choose flavour, consistency, toppings

See real-time drink price calculations

Frequent customer discount applied dynamically

Secure checkout & payment

Receive confirmation email + receipt

View order history and receipts

 **Management Features**
Lookup management:

Flavours

Toppings

Consistencies

Configurable settings:

VAT % (default 15%)

Min/max drinks per order

Discount tiers & caps

Full auditing of every field changed

Reports:

Orders per period

Customer volume by day of week

Lookup changes & who changed what

**Discount System**
The backend includes a fully configurable discount engine:

Tier 1

Tier 2

Tier 3

Each tier is configured in the database according to the rules described in the requirements document.
This includes:

Minimum orders

Minimum drinks per order

Maximum discount cap

Calculation of actual discount vs capped discount

**Payment Gateway**


After successful payment:

Order is confirmed

Receipt is emailed

Payment audit saved

Patron order history updated

**Database Design**

Core tables:

Users

Orders

OrderDrinks

Lookups (Flavour / Topping / Consistency)

Configurations

AuditLogs

Payments

Restaurants

Every change is fully audited.



**Frontend (Flutter)**

Flutter supports:

Web (Chrome)

Android

iOS (optional)

Windows desktop

Includes:

Login screen

Order creation screen

Lookup management screen

Reports screen

Dashboard for patrons

 **Tech Stack**

Layer	Technology
Frontend	Flutter
Backend	ASP.NET Core Web API (.NET 8)
Authentication	JWT + Refresh Tokens
Database	SQL Server / LocalDB
ORM	Entity Framework Core
Logging & Auditing	Custom middleware + SQL
Payments	PayFast / Stripe
Email	SMTP / SendGrid
Architecture	Clean Architecture + Repository + Unit of Work

**Project Structure**
MilkshakeAPI.Domain/             |
MilkshakeAPI.Application/        | 
MilkshakeAPI.Infrastructure/     |   ← C# Backend
MilkshakeAPI.Web/                |

milkshake_app/   ← Flutter frontend


Each backend layer follows clean architecture:

Domain: Entities, interfaces

Application: DTOs, services, business logic

Infrastructure: EF Core, repositories, payment services

Web: Controllers, startup configuration

**Setup Instructions**
Backend

Install SQL Server or LocalDB

Update appsettings.json connection string

Run migrations:

Update-Database


Run API:

dotnet run

Frontend

Open Flutter project

Run

flutter pub get
flutter run

 **Seed Data**

The project includes seed data for:

Flavours

Consistencies

Toppings

Restaurants

Configurations (VAT, max drinks, discount tiers)

**Screenshots**

Login and Register Page:
<img width="1358" height="718" alt="image" src="https://github.com/user-attachments/assets/50253416-0be9-46c5-9759-34f589fd7a08" />
<img width="1359" height="719" alt="image" src="https://github.com/user-attachments/assets/a916b5b5-7913-4269-a9b6-3c08e1402657" />



Home Page:
<img width="1360" height="727" alt="image" src="https://github.com/user-attachments/assets/821c8a2f-2707-47d0-b8ae-eb7e35bdf2e6" />
<img width="1358" height="727" alt="image" src="https://github.com/user-attachments/assets/0a46255a-dce3-4490-91fa-a37772c48a60" />
<img width="1360" height="723" alt="image" src="https://github.com/user-attachments/assets/c3a4ab29-695d-467d-8b10-4f6d3213fa29" />

Lookup management Page:
<img width="1359" height="725" alt="image" src="https://github.com/user-attachments/assets/399069ed-8ce1-4654-ada8-e3c5e4af11be" />
<img width="1359" height="729" alt="image" src="https://github.com/user-attachments/assets/c4034795-5726-41b2-ade1-b17af39439ec" />

Reports Page:
<img width="1357" height="733" alt="image" src="https://github.com/user-attachments/assets/1fb5513f-d403-4fe6-8ff4-57df59d75fde" />
<img width="1360" height="736" alt="image" src="https://github.com/user-attachments/assets/848821ef-3c1b-499c-b6ef-70fc321232e6" />

Configuration Management Page:
<img width="1360" height="728" alt="image" src="https://github.com/user-attachments/assets/1646823a-dff2-4957-ab54-bdd58a821d5c" />

Profile Page:
<img width="1359" height="722" alt="image" src="https://github.com/user-attachments/assets/30d19093-e1f8-4913-825f-39a4b8615b9b" />

Order Placement Page:
<img width="1351" height="720" alt="image" src="https://github.com/user-attachments/assets/5896168e-8b61-45bd-a75d-9b41445792cf" />

Restaurant and Time Selection Page:
<img width="1359" height="716" alt="image" src="https://github.com/user-attachments/assets/cd80e222-7db1-43e1-ba04-287e9bdb792a" />
<img width="1359" height="722" alt="image" src="https://github.com/user-attachments/assets/2c597a57-e2eb-4178-94bb-89b38e56ded1" />

Payment Page:
<img width="1357" height="720" alt="image" src="https://github.com/user-attachments/assets/13f42481-b51e-41e1-aa0d-f8a5ca1e07c7" />

Payment Success Page:
<img width="1358" height="720" alt="image" src="https://github.com/user-attachments/assets/fa41c54d-b652-4f78-8f2c-a0ab4635a9da" />
<img width="1354" height="718" alt="image" src="https://github.com/user-attachments/assets/c36c064f-a32e-4976-a6f5-b6b43bcf7d59" />

