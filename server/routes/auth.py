import bcrypt
import uuid
import jwt
import os
from fastapi import Depends, HTTPException
from database import get_db
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from fastapi import APIRouter
from sqlalchemy.orm import Session
from middleware.auth_middleware import auth_middleware

router = APIRouter()


@router.post("/signup", status_code=201)
# using Depends, we first yield db, once the signup function finishes db is closed
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # check if the user already exists in db
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(400, "User with the same email exists!")

    hashed_password = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(
        id=str(uuid.uuid4()), email=user.email, password=hashed_password, name=user.name
    )
    # add the user to the db
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    return user_db


@router.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    # check if the user with the same email exists in db
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(400, "User with this email does not exist!")

    # password matching or not
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)

    if not is_match:
        raise HTTPException(400, "Incorrect password!")

    token = jwt.encode({"id": user_db.id}, os.getenv("JWT_KEY"), "HS256")
    return {"token": token, "user": user_db}


@router.get("/")
def current_user_data(
    db: Session = Depends(get_db), user_dict=Depends(auth_middleware)
):
    user = db.query(User).filter(User.id == user_dict["uid"]).first()

    if not user:
        raise HTTPException(404, "User not found!")

    return user
