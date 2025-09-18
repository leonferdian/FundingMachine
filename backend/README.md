# Funding Machine Backend

This is the backend service for the Funding Machine application, built with Node.js, TypeScript, Express, and Prisma.

## Features

- 🔐 Authentication & Authorization
- 💳 Bank Account Management
- 💰 Funding Platform Integration
- 🤖 AI-Powered Operations
- 💸 Payment Processing
- 📊 Transaction Management
- 🔄 Subscription Management

## Prerequisites

- Node.js 18+
- PostgreSQL
- npm or yarn
- Prisma CLI

## Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FundingMachine/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   Copy `.env.example` to `.env` and update the values:
   ```bash
   cp .env.example .env
   ```

4. **Set up database**
   Update the `DATABASE_URL` in `.env` with your PostgreSQL connection string.

5. **Run database migrations**
   ```bash
   npx prisma migrate dev --name init
   ```

6. **Generate Prisma Client**
   ```bash
   npx prisma generate
   ```

## API Documentation

### Authentication

#### Register a new user
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "securepassword123"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "securepassword123"
}
```

### Bank Accounts

#### Add a bank account
```http
POST /api/bank-accounts
Authorization: Bearer <token>
Content-Type: application/json

{
  "bankName": "Bank Example",
  "accountName": "John Doe",
  "accountNumber": "1234567890",
  "bankCode": "BANK123",
  "isDefault": true
}
```

#### Get user's bank accounts
```http
GET /api/bank-accounts
Authorization: Bearer <token>
```

### Funding Platforms

#### Get available funding platforms
```http
GET /api/funding-platforms
Authorization: Bearer <token>
```

### Fundings

#### Create a new funding
```http
POST /api/funding
Authorization: Bearer <token>
Content-Type: application/json

{
  "platformId": "<platform-id>",
  "amount": 1000000,
  "profitShare": 70
}
```

#### Get user's fundings
```http
GET /api/funding
Authorization: Bearer <token>
```

### Transactions

#### Get transaction history
```http
GET /api/transactions
Authorization: Bearer <token>
```

#### Request withdrawal
```http
POST /api/transactions/withdraw
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 500000,
  "bankAccountId": "<bank-account-id>",
  "description": "Withdrawal request"
}
```

### Subscriptions

#### Get subscription plans
```http
GET /api/subscriptions/plans
```

#### Get current subscription
```http
GET /api/subscriptions/current
Authorization: Bearer <token>
```

#### Create a subscription
```http
POST /api/subscriptions
Authorization: Bearer <token>
Content-Type: application/json

{
  "planId": "plan_monthly",
  "paymentMethod": "credit_card"
}
```

## Environment Variables

- `PORT`: Server port (default: 5000)
- `NODE_ENV`: Environment (development/production)
- `DATABASE_URL`: PostgreSQL connection URL
- `JWT_SECRET`: Secret for JWT token generation
- `JWT_EXPIRE`: JWT token expiration time
- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_CLIENT_EMAIL`: Firebase client email
- `FIREBASE_PRIVATE_KEY`: Firebase private key
- `OPENAI_API_KEY`: OpenAI API key
- `MIDTRANS_SERVER_KEY`: Midtrans server key
- `MIDTRANS_CLIENT_KEY`: Midtrans client key
- `XENDIT_SECRET_KEY`: Xendit secret key

## Development

### Running the server
```bash
# Development
npm run dev

# Production
npm run build
npm start
```

### Running tests
```bash
npm test
```

### Linting
```bash
npm run lint
```

## Deployment

The application can be deployed using Docker:

```bash
docker build -t funding-machine-backend .
docker run -p 5000:5000 funding-machine-backend
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
   ```

## Development

- **Start development server**
  ```bash
  npm run dev
  ```

- **Build for production**
  ```bash
  npm run build
  ```

- **Run production server**
  ```bash
  npm start
  ```

- **Access Prisma Studio**
  ```bash
  npx prisma studio
  ```

## API Documentation

API documentation is available at `/api-docs` when running in development mode.

## Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## Environment Variables

- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment (development/production)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret key for JWT
- `FIREBASE_*` - Firebase Admin SDK credentials
- `OPENAI_API_KEY` - OpenAI API key for AI features
- `MIDTRANS_*` - Midtrans payment gateway credentials
- `XENDIT_API_KEY` - Xendit payment gateway API key

## Project Structure

```
src/
├── config/         # Configuration files
├── controllers/    # Route controllers
├── middleware/     # Express middlewares
├── models/         # Database models
├── routes/         # API routes
├── services/       # Business logic
├── types/          # TypeScript type definitions
└── utils/          # Utility functions
```

## License

MIT
