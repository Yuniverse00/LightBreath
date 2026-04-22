package com.amplifyframework.datastore.generated.model;

import com.amplifyframework.core.model.temporal.Temporal;

import java.util.List;
import java.util.UUID;
import java.util.Objects;

import androidx.core.util.ObjectsCompat;

import com.amplifyframework.core.model.AuthStrategy;
import com.amplifyframework.core.model.Model;
import com.amplifyframework.core.model.ModelOperation;
import com.amplifyframework.core.model.annotations.AuthRule;
import com.amplifyframework.core.model.annotations.Index;
import com.amplifyframework.core.model.annotations.ModelConfig;
import com.amplifyframework.core.model.annotations.ModelField;
import com.amplifyframework.core.model.query.predicate.QueryField;

import static com.amplifyframework.core.model.query.predicate.QueryField.field;

/** This is an auto generated class representing the UserSmokingReport type in your schema. */
@SuppressWarnings("all")
@ModelConfig(pluralName = "UserSmokingReports", authRules = {
  @AuthRule(allow = AuthStrategy.OWNER, ownerField = "owner", identityClaim = "cognito:username", provider = "userPools", operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ }),
  @AuthRule(allow = AuthStrategy.PRIVATE, operations = { ModelOperation.CREATE, ModelOperation.UPDATE, ModelOperation.DELETE, ModelOperation.READ })
})
public final class UserSmokingReport implements Model {
  public static final QueryField ID = field("UserSmokingReport", "id");
  public static final QueryField USERNAME = field("UserSmokingReport", "username");
  public static final QueryField TIMESTAMP = field("UserSmokingReport", "timestamp");
  public static final QueryField STATUS = field("UserSmokingReport", "status");
  private final @ModelField(targetType="ID", isRequired = true) String id;
  private final @ModelField(targetType="String", isRequired = true) String username;
  private final @ModelField(targetType="String", isRequired = true) String timestamp;
  private final @ModelField(targetType="SmokingStatus", isRequired = true) SmokingStatus status;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime createdAt;
  private @ModelField(targetType="AWSDateTime", isReadOnly = true) Temporal.DateTime updatedAt;
  public String getId() {
      return id;
  }
  
  public String getUsername() {
      return username;
  }
  
  public String getTimestamp() {
      return timestamp;
  }
  
  public SmokingStatus getStatus() {
      return status;
  }
  
  public Temporal.DateTime getCreatedAt() {
      return createdAt;
  }
  
  public Temporal.DateTime getUpdatedAt() {
      return updatedAt;
  }
  
  private UserSmokingReport(String id, String username, String timestamp, SmokingStatus status) {
    this.id = id;
    this.username = username;
    this.timestamp = timestamp;
    this.status = status;
  }
  
  @Override
   public boolean equals(Object obj) {
      if (this == obj) {
        return true;
      } else if(obj == null || getClass() != obj.getClass()) {
        return false;
      } else {
      UserSmokingReport userSmokingReport = (UserSmokingReport) obj;
      return ObjectsCompat.equals(getId(), userSmokingReport.getId()) &&
              ObjectsCompat.equals(getUsername(), userSmokingReport.getUsername()) &&
              ObjectsCompat.equals(getTimestamp(), userSmokingReport.getTimestamp()) &&
              ObjectsCompat.equals(getStatus(), userSmokingReport.getStatus()) &&
              ObjectsCompat.equals(getCreatedAt(), userSmokingReport.getCreatedAt()) &&
              ObjectsCompat.equals(getUpdatedAt(), userSmokingReport.getUpdatedAt());
      }
  }
  
  @Override
   public int hashCode() {
    return new StringBuilder()
      .append(getId())
      .append(getUsername())
      .append(getTimestamp())
      .append(getStatus())
      .append(getCreatedAt())
      .append(getUpdatedAt())
      .toString()
      .hashCode();
  }
  
  @Override
   public String toString() {
    return new StringBuilder()
      .append("UserSmokingReport {")
      .append("id=" + String.valueOf(getId()) + ", ")
      .append("username=" + String.valueOf(getUsername()) + ", ")
      .append("timestamp=" + String.valueOf(getTimestamp()) + ", ")
      .append("status=" + String.valueOf(getStatus()) + ", ")
      .append("createdAt=" + String.valueOf(getCreatedAt()) + ", ")
      .append("updatedAt=" + String.valueOf(getUpdatedAt()))
      .append("}")
      .toString();
  }
  
  public static UsernameStep builder() {
      return new Builder();
  }
  
  /**
   * WARNING: This method should not be used to build an instance of this object for a CREATE mutation.
   * This is a convenience method to return an instance of the object with only its ID populated
   * to be used in the context of a parameter in a delete mutation or referencing a foreign key
   * in a relationship.
   * @param id the id of the existing item this instance will represent
   * @return an instance of this model with only ID populated
   */
  public static UserSmokingReport justId(String id) {
    return new UserSmokingReport(
      id,
      null,
      null,
      null
    );
  }
  
  public CopyOfBuilder copyOfBuilder() {
    return new CopyOfBuilder(id,
      username,
      timestamp,
      status);
  }
  public interface UsernameStep {
    TimestampStep username(String username);
  }
  

  public interface TimestampStep {
    StatusStep timestamp(String timestamp);
  }
  

  public interface StatusStep {
    BuildStep status(SmokingStatus status);
  }
  

  public interface BuildStep {
    UserSmokingReport build();
    BuildStep id(String id);
  }
  

  public static class Builder implements UsernameStep, TimestampStep, StatusStep, BuildStep {
    private String id;
    private String username;
    private String timestamp;
    private SmokingStatus status;
    @Override
     public UserSmokingReport build() {
        String id = this.id != null ? this.id : UUID.randomUUID().toString();
        
        return new UserSmokingReport(
          id,
          username,
          timestamp,
          status);
    }
    
    @Override
     public TimestampStep username(String username) {
        Objects.requireNonNull(username);
        this.username = username;
        return this;
    }
    
    @Override
     public StatusStep timestamp(String timestamp) {
        Objects.requireNonNull(timestamp);
        this.timestamp = timestamp;
        return this;
    }
    
    @Override
     public BuildStep status(SmokingStatus status) {
        Objects.requireNonNull(status);
        this.status = status;
        return this;
    }
    
    /**
     * @param id id
     * @return Current Builder instance, for fluent method chaining
     */
    public BuildStep id(String id) {
        this.id = id;
        return this;
    }
  }
  

  public final class CopyOfBuilder extends Builder {
    private CopyOfBuilder(String id, String username, String timestamp, SmokingStatus status) {
      super.id(id);
      super.username(username)
        .timestamp(timestamp)
        .status(status);
    }
    
    @Override
     public CopyOfBuilder username(String username) {
      return (CopyOfBuilder) super.username(username);
    }
    
    @Override
     public CopyOfBuilder timestamp(String timestamp) {
      return (CopyOfBuilder) super.timestamp(timestamp);
    }
    
    @Override
     public CopyOfBuilder status(SmokingStatus status) {
      return (CopyOfBuilder) super.status(status);
    }
  }
  
}
