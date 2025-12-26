import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv()


engine = create_engine(os.getenv("DATABASE_URL"))

# with auto commit false we only commit one transaction of commiting frequently
# with auto flush true, queries operate on the most recent written data which can lead to performance issues
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# use get_db for dependency injection and proper lifecylce management of db
# we want to properly close db conn once the function accessing db is done
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
