//
//  MTMigrationTests.m
//  MTMigrationTests
//
//  Created by Parker Wightman on 2/7/13.
//  Copyright (c) 2013 Mysterious Trousers. All rights reserved.
//

#import "MTMigrationTests.h"
#import "MTMigration.h"

@implementation MTMigrationTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testMigrationReset
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
    
	[MTMigration migrateToVersion:@"0.9" block:^{
		val++;
	}];
    
	[MTMigration migrateToVersion:@"1.0" block:^{
		val++;
	}];
	
	[MTMigration reset];

	[MTMigration migrateToVersion:@"0.9" block:^{
		val++;
	}];
    
	[MTMigration migrateToVersion:@"1.0" block:^{
		val++;
	}];
	
	STAssertEquals(val, 4, @"Should execute all migrations again after reset");
    
}

- (void)testMigratesOnFirstRun
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
	
	[MTMigration migrateToVersion:@"1.0" block:^{
		val = 1;
	}];
	
	STAssertEquals(val, 1, @"Should execute migration after reset");
	
}

- (void)testMigratesOnce
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
	
	[MTMigration migrateToVersion:@"1.0" block:^{
	}];
	
	[MTMigration migrateToVersion:@"1.0" block:^{
		val = 1;
	}];
	
	STAssertEquals(val, 0, @"Should not execute a block for the same version twice.");
	
}

- (void)testMigratesPreviousBlocks
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
	
	[MTMigration migrateToVersion:@"0.9" block:^{
		val++;
	}];
	
	[MTMigration migrateToVersion:@"1.0" block:^{
		val++;
	}];
	
	STAssertEquals(val, 2, @"Should execute any migrations that have not run yet");
	
}

- (void)testMigratesInNaturalSortOrder
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
	
	[MTMigration migrateToVersion:@"0.9" block:^{
		val++;
	}];
	
	[MTMigration migrateToVersion:@"0.10" block:^{
		val*=2;
	}];
	
	STAssertEquals(val, 2, @"Should use natural sort order, e.g. treat 0.10 as a follower of 0.9");
	
}

- (void)testRunsApplicationUpdateBlockOnce
{
    [MTMigration reset];
    
    __block NSInteger val = 0;
    
    [MTMigration applicationUpdateBlock:^{
        val++;
    }];
    
    [MTMigration applicationUpdateBlock:^{
        val++;
    }];
    
    STAssertEquals(val, 1, @"Should only call block once");
}

- (void)testRunsApplicationUpdateBlockeOnlyOnceWithMultipleMigrations
{
	[MTMigration reset];
	
	__block NSInteger val = 0;
    
    [MTMigration migrateToVersion:@"0.8" block:^{
		// Do something
	}];
	
	[MTMigration migrateToVersion:@"0.9" block:^{
		// Do something
	}];
	
	[MTMigration migrateToVersion:@"0.10" block:^{
		// Do something
	}];
    
    [MTMigration applicationUpdateBlock:^{
        val = 1;
    }];
	
	STAssertEquals(val, 1, @"Should call the applicationUpdateBlock only once no matter how many migrations have to be done.");
	
}

@end
