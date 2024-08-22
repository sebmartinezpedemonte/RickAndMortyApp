# Rick and Morty Salesforce Integration

This project is a Salesforce integration application that fetches data from the Rick and Morty API and displays it within Salesforce. The application allows users to view and manage data related to Rick and Morty characters directly from a Salesforce Lightning Web Component (LWC) and Visualforce pages.

## Features

* **Fetch and Display Characters**: The app fetches data from the Rick and Morty API and upserts it into Salesforce custom objects.
* **Character Listing**: A Lightning Web Component displays a list of characters with sorting and filtering options.
* **Detailed View**: Users can click on a character's name to view detailed information about the character.
* **Batch Upsert**: The app includes a batchable Apex class to periodically update character data using the Salesforce scheduler.
* **Custom Permissions**: Configured permissions ensure that only specific users can access certain functionalities based on the character's status (alive or dead).

## Components

1. **RickAndMortyBatchUpsert**
   * A batchable Apex class that retrieves characters from the Rick and Morty API and upserts them into Salesforce.
   * The class handles large data sets by breaking down the API calls into manageable batches.
   * It logs successful and failed records for further analysis.
   
2. **RickAndMortyBatchUpsertScheduler**
   * A scheduler class that automates the batch upsert process.
   * It is configured to run on weekdays at 19:00 hours.
   
3. **CharactersController**
   * An Apex controller that provides data to the Lightning Web Component.
   * It includes methods to fetch, sort, and filter character data.
   
4. **Lightning Web Component (LWC)**
   * Displays a datatable with all custom attributes of the characters.
   * Includes sorting functionality by `ExtId__c` and `Name`.
   * Users can click on a character name to navigate to the character's detailed view page.
   
5. **Test Classes**
   * Comprehensive test coverage for all the custom Apex classes and controllers.
   * Tests ensure that the application meets Salesforce's best practices and coverage requirements.

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/sebmartinezpedemonte/RickAndMortyApp.git
    ```

2. Deploy the source code to your Salesforce org using your preferred deployment tool (e.g., Salesforce CLI, Workbench).

3. Set up the necessary custom objects, fields, and permissions in your Salesforce org as outlined in the project documentation.

4. Schedule the `RickAndMortyBatchUpsertScheduler` using the Salesforce Scheduler.

## Usage

* Navigate to the app's custom tab to view the list of Rick and Morty characters.
* Click on any character name to see more detailed information.
* The batch job runs automatically on weekdays to keep the character data up to date.

## Contributing

Feel free to fork the repository, create a new branch, and submit a pull request if you want to contribute to the project.

## Detailed Documentation

### Capgemini Salesforce Academy - Final Project Documentation
**Author:** Sebastian Martinez Pedemonte

### Users

* `adminuser@company.com.martinez`
* `cesaruser@company.com.martinez`
* `damianuser@company.com.martinez`

### Component Details

| Point | API Name                         | Type          | Description                                           |
|-------|----------------------------------|---------------|-------------------------------------------------------|
| 2.1   | `Personaje__c`                   | Object        | Custom Object                                         |
| 2.2   | `RickAndMortyBatchUpsert`        | Apex Class    | Data loading using Batchable                          |
| 2.2   | `RickAndMortyBatchUpsertScheduler`| Apex Class    | Bonus Schedulable class                               |
| 2.3   | `Rick_and_Morty`                 | Custom App    | Rick and Morty Custom App                             |
| 2.4   | `c`                              | LWC Component | Custom Tab displaying the list of characters          |
| 2.4   | `CharactersController`           | Apex Class    | Class that returns a list of characters in the database to be used by the LWC |
| 2.5   | `Acceso_Objeto_Personaje`        | Permission Set| Permission set for granting access to the `Personaje` object to César and Damián |
| 2.5   | `Dead_Characters_Group`          | Public Group  | Public group where Damián is a member                 |
| 2.5   | `Alive_Characters_Group`         | Public Group  | Public group where César is a member                  |
| 2.5   | `Dead_Characters_Rule`           | Sharing Rule  | Rule allowing Damián to see characters with status 'Dead' |
| 2.5   | `Alive_Characters_Rule`          | Sharing Rule  | Rule allowing César to see characters with status 'Alive' |
| 2.6   | `CharactersControllerTest`       | Apex Class    | Test class for `CharactersController`                 |
| 2.6   | `RickAndMortyBatchUpsertTest`    | Apex Class    | Test class for `RickAndMortyBatchUpsert`              |
| 2.6   | `RickAndMortyBatchUpsertSchedulerTest`| Apex Class | Test class for `RickAndMortyBatchUpsertScheduler`     |
| 2.6   | `RickAndMortyApiCalloutMock`     | Apex Class    | Class implementing the `HttpCalloutMock` interface used in the `RickAndMortyBatchUpsertTest` class |
| 2.6   | `RickAndMortyApiCalloutMockWithError`| Apex Class | Class implementing the `HttpCalloutMock` interface used in the `RickAndMortyBatchUpsertTest` class |
| 2.6   | `RickAndMortyMockHttpErrorResponse`| Apex Class  | Class implementing the `HttpCalloutMock` interface used in the `RickAndMortyBatchUpsertTest` class |

### 2.1 Data Modeling

#### Field Configuration

* **ExtId**: Number, Unique, External Id
* **Name**: Text
* **Status**: Picklist ('Alive', 'Dead', 'Unknown')
* **Species**: Text
* **Gender**: Picklist ('Female', 'Male', 'Genderless', 'Unknown')
* **ImageUrl**: URL
* **Image**: Formula (Text) - Displays the image from `ImageURL`
* **Url**: URL

**Explanation of Field Choices:**

* **ExtId**: Chosen as Number because the API provides it as an Integer.
* **Name**: Chosen as Text due to the large number of possible values.
* **Species**: Chosen as Text because the API returns a variety of values, not just 3 or 4 like with Status and Gender.
* **Gender**: Chosen as Picklist with four possible values from the API.
* **Image**: Created as a Formula field using the `IMAGE` function to display the image.
* **Url**: Chosen as URL type to ensure that the string from the API functions as a link.

### 2.2 Data Loading

Created the `RickAndMortyBatchUpsert` class to load data in batches.

#### Attributes:

* `Integer successfulUpserts = 0`: Counts successfully inserted or updated records.
* `Integer failedUpserts = 0`: Counts records that generated errors during execution.
* `Integer errorsFindingCharacter = 0`: Counts records that encountered errors when being searched in the API.
* `Integer errorsAPICall = 0`: Counts the number of errors during API calls.
* `final static Integer TOTAL_AMOUNT_OF_CHARACTERS = 826`: Total characters to insert/update.
* `final static Integer BATCH_SIZE = 100`: Batch size to avoid exceeding API call governance limits.

#### Methods:

* **`public static String runBatchWithFixedScope()`**:
  * Executes the batch with a fixed batch size (100). This size is adjusted to avoid exceeding the governance limit of 100 callouts per transaction. Run using `RickAndMortyBatchUpsert.runBatchWithFixedScope();` in the Anonymous Window.
* **`public Iterable<Personaje__c> start(Database.BatchableContext bc)`**:
  * Generates a list of characters with `ExtId` from 1 to 826 to be processed during execution. If running a test, limits the number of characters to 100.
* **`public void execute(Database.BatchableContext bc, List<Personaje__c> scope)`**:
  * For each batch of character IDs, makes an HTTP call to the Rick and Morty API to get character details, maps the data to a new `Personaje__c` object in Salesforce, and calls the private method `upsertCharacters` to insert/update characters if the list is not empty.
* **`private void upsertCharacters(List<Personaje__c> charactersUpsert)`**:
  * Inserts or updates `Personaje__c` objects in Salesforce using `Database.upsert(charactersToUpsert, Personaje__c.ExtId__c, false);` with `ExtId__c` as a reference and sets the third parameter to `false` to configure `AllOrNone` to `false`.

#### Ways to Execute the Class:

1. Running this code in the Anonymous Window:
   
    ```java
    RickAndMortyBatchUpsert batch = new RickAndMortyBatchUpsert();
    Database.executeBatch(batch,100);
    ```

2. Scheduling the job using the `RickAndMortyBatchUpsertScheduler` class.

### 2.3 App Configuration

* Created a Custom App named **Rick and Morty**.
* Created a custom tab to access the list of characters (datatabled displayed in a Lightning Web Component).

### 2.4 Implemented Custom Lightning Web Component (LWC)

* Displays all fields from the `Personaje__c` object with the ability to sort by `ExtId__c` and `Name`.

### 2.5 Security Configuration

* **Created Permission Set**: Named `Acceso_Objeto_Personaje`, which allows access to the `Personaje__c` object.
* **Created Public Groups**:
  * **Dead_Characters_Group**: Members can see only characters with the status "Dead".
  * **Alive_Characters_Group**: Members can see only characters with the status "Alive".
* **Created Sharing Rules**:
  * **Dead_Characters_Rule**: Allows Damián to see characters with the status "Dead".
  * **Alive_Characters_Rule**: Allows César to see characters with the status "Alive".

### 2.6 Test Coverage

Created test classes to cover the main classes in the project:

* **CharactersControllerTest**: Covers the `CharactersController` class.
* **RickAndMortyBatchUpsertTest**: Covers the `RickAndMortyBatchUpsert` class.
* **RickAndMortyBatchUpsertSchedulerTest**: Covers the `RickAndMortyBatchUpsertScheduler` class.

Each test class includes a `setup` method to insert test records and test methods to validate expected outcomes using `System.assert`.

#### Mock Callout Classes:

* **RickAndMortyApiCalloutMock**: Implements `HttpCalloutMock` for successful responses.
* **RickAndMortyApiCalloutMockWithError**: Implements `HttpCalloutMock` for API errors.
* **RickAndMortyMockHttpErrorResponse**: Implements `HttpCalloutMock` for HTTP error responses.


# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
