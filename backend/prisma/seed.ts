import { PrismaClient } from '@prisma/client';
import { hash } from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create admin user
  const adminPassword = await hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@fundingmachine.com' },
    update: {},
    create: {
      name: 'Admin User',
      email: 'admin@fundingmachine.com',
      password: adminPassword,
      isVerified: true,
      role: 'ADMIN',
    },
  });

  // Create subscription plans
  const basicPlan = await prisma.subscriptionPlan.upsert({
    where: { name: 'Basic Plan' },
    update: {},
    create: {
      name: 'Basic Plan',
      description: 'Perfect for getting started',
      price: 9.99,
      duration: 30, // 30 days
      isActive: true,
      features: JSON.stringify([
        'Basic funding options',
        'Email support',
        'Access to community forums'
      ]),
    },
  });

  const proPlan = await prisma.subscriptionPlan.upsert({
    where: { name: 'Pro Plan' },
    update: {},
    create: {
      name: 'Pro Plan',
      description: 'For power users and professionals',
      price: 29.99,
      duration: 30, // 30 days
      isActive: true,
      features: JSON.stringify([
        'All Basic features',
        'Priority support',
        'Advanced analytics',
        'API access',
        'Custom funding strategies'
      ]),
    },
  });

  // Create funding platforms
  const adPlatform = await prisma.fundingPlatform.upsert({
    where: { name: 'Ad Revenue' },
    update: {},
    create: {
      name: 'Ad Revenue',
      type: 'ADS',
      description: 'Earn from ad impressions and clicks',
      isActive: true,
    },
  });

  const surveyPlatform = await prisma.fundingPlatform.upsert({
    where: { name: 'Surveys' },
    update: {},
    create: {
      name: 'Surveys',
      type: 'SURVEY',
      description: 'Earn by completing surveys',
      isActive: true,
    },
  });

  console.log('✅ Database seeded successfully!');
  console.log('👤 Admin user created:');
  console.log(`   Email: admin@fundingmachine.com`);
  console.log(`   Password: admin123`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
