import bcrypt
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy import TEXT, VARCHAR, LargeBinary, create_engine, Column
from dotenv import load_dotenv
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

import os
import uuid

load_dotenv()


app = FastAPI()

engine = create_engine(os.getenv("DATABASE_URL"))

# with auto commit false we only commit one transaction of commiting frequently
# with auto flush true, queries operate on the most recent written data which can lead to performance issues
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

db = SessionLocal()


class UserCreate(BaseModel):
    name: str
    email: str
    password: str


Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)


@app.post("/signup")
def signup_user(user: UserCreate):
    # check if the user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        return HTTPException(400, "User with the same email exists!")

    hashed_password = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(
        id=str(uuid.uuid4()), email=user.email, password=hashed_password, name=user.name
    )
    # add the user to the db
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db


Base.metadata.create_all(engine)
